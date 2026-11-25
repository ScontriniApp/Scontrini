"""Helpers for tool/release_check/run.sh (standard library only).

  python release_check.py scanned-pdf PHOTO.jpg OUT.pdf
      Wraps a JPEG in a one-page PDF with no text layer, so the check also
      covers scanned PDFs (pdfrx renders the page, then OCR).

  python release_check.py compare DEBUG_DIR RELEASE_DIR
      Compares the two output folders. Exit code 1 on any difference or on
      an error in either mode.
"""

import json
import struct
import sys
from pathlib import Path


def scanned_pdf(photo: str, out: str) -> None:
    jpg = Path(photo).read_bytes()
    i = 2
    while True:  # walk the JPEG segments up to the frame header (size)
        marker = jpg[i + 1]
        length = struct.unpack(">H", jpg[i + 2 : i + 4])[0]
        if marker in (0xC0, 0xC1, 0xC2):
            height, width = struct.unpack(">HH", jpg[i + 5 : i + 9])
            break
        i += 2 + length
    w, h = round(width * 72 / 150), round(height * 72 / 150)  # 150 dpi page
    content = f"q {w} 0 0 {h} 0 0 cm /Im0 Do Q".encode()
    objects = [
        b"<< /Type /Catalog /Pages 2 0 R >>",
        b"<< /Type /Pages /Kids [3 0 R] /Count 1 >>",
        f"<< /Type /Page /Parent 2 0 R /MediaBox [0 0 {w} {h}] "
        f"/Resources << /XObject << /Im0 4 0 R >> >> /Contents 5 0 R >>".encode(),
        f"<< /Type /XObject /Subtype /Image /Width {width} /Height {height} "
        f"/ColorSpace /DeviceRGB /BitsPerComponent 8 /Filter /DCTDecode "
        f"/Length {len(jpg)} >>\nstream\n".encode()
        + jpg
        + b"\nendstream",
        b"<< /Length %d >>\nstream\n" % len(content) + content + b"\nendstream",
    ]
    pdf = b"%PDF-1.4\n"
    offsets = []
    for n, body in enumerate(objects, 1):
        offsets.append(len(pdf))
        pdf += b"%d 0 obj\n" % n + body + b"\nendobj\n"
    xref = len(pdf)
    pdf += b"xref\n0 %d\n0000000000 65535 f \n" % (len(objects) + 1)
    pdf += b"".join(b"%010d 00000 n \n" % o for o in offsets)
    pdf += b"trailer << /Size %d /Root 1 0 R >>\nstartxref\n%d\n%%%%EOF\n" % (
        len(objects) + 1,
        xref,
    )
    Path(out).write_bytes(pdf)


def compare(debug_dir: str, release_dir: str) -> int:
    debug, release = Path(debug_dir), Path(release_dir)
    problems = []
    for mode_dir in (debug, release):
        done = (mode_dir / "done").read_text(encoding="utf-8") if (
            mode_dir / "done"
        ).exists() else "missing"
        if done != "ok":
            problems.append(f"{mode_dir.name} did not finish: {done[:300]}")

    native_d = json.loads((debug / "native.json").read_text(encoding="utf-8"))
    native_r = json.loads((release / "native.json").read_text(encoding="utf-8"))
    for name in native_d:
        d, r = native_d[name], native_r.get(name)
        ok = d == r and not str(d).startswith("ERROR")
        print(f"{'ok  ' if ok else 'FAIL'} {name}: {r}")
        if not ok:
            problems.append(f"{name}: debug {d} / release {r}")

    for name in ("paddle", "mlkit", "pdf"):
        d_path, r_path = debug / f"{name}.json", release / f"{name}.json"
        if not d_path.exists() or not r_path.exists():
            problems.append(f"{name}: no output")
            continue
        d_cases = json.loads(d_path.read_text(encoding="utf-8"))
        r_cases = json.loads(r_path.read_text(encoding="utf-8"))
        same = 0
        for d, r in zip(d_cases, r_cases):
            errors = d.get("error") or r.get("error")
            # OCR boxes, rows and the parsed receipt (prices, VAT, quantities,
            # discounts, totals, date, store) must match exactly.
            fields = ("textSource", "document", "rows", "parsed")
            diff = [k for k in fields if d.get(k) != r.get(k)]
            if errors or diff:
                first_line = str(errors).splitlines()[0][:200] if errors else ""
                problems.append(f"{name}/{d['name']}: {first_line or diff}")
            else:
                same += 1
        total = max(len(d_cases), len(r_cases))
        print(f"{'ok  ' if same == total else 'FAIL'} {name}: "
              f"{same}/{total} receipts identical")

    if problems:
        print("\nRelease differs from debug:")
        for problem in problems:
            print(f"  - {problem}")
        return 1
    print("\nRelease matches debug.")
    return 0


if __name__ == "__main__":
    command, *args = sys.argv[1:]
    if command == "scanned-pdf":
        scanned_pdf(*args)
    elif command == "compare":
        sys.exit(compare(*args))
    else:
        sys.exit(f"unknown command {command}")
