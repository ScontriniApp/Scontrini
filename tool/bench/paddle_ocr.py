"""Reads receipt photos with PaddleOCR (PP-OCR ONNX models, via RapidOCR) on
the PC and saves the result as OcrDocument JSON for the extraction benchmark.

The same ONNX models run on Android with onnxruntime, so what this measures
on the PC is what the phone would read. No device or emulator is involved.

Setup (once, outside git):
    python -m venv .tooling/paddle-venv
    .tooling/paddle-venv/Scripts/python -m pip install rapidocr onnxruntime

Run:
    .tooling/paddle-venv/Scripts/python tool/bench/paddle_ocr.py [--model NAME]
        [--photos DIR ...] [--out DIR] [--refresh]

Writes data/ocr_cache/paddle_<model>/<name>.ocr.json, which
`flutter test tool/bench/desktop_bench_test.dart` then scores as the group
"photos · PaddleOCR <model>". Photos already read are skipped unless --refresh.
"""

import argparse
import json
import math
import re
import sys
import time
from pathlib import Path

from rapidocr import LangDet, LangRec, ModelType, OCRVersion, RapidOCR

# Model sets worth comparing. Latin recognition matters for Italian accents.
MODELS = {
    'v5-mobile': {
        'Det.ocr_version': OCRVersion.PPOCRV5,
        'Det.model_type': ModelType.MOBILE,
        'Det.lang_type': LangDet.CH,
        'Rec.ocr_version': OCRVersion.PPOCRV5,
        'Rec.model_type': ModelType.MOBILE,
        'Rec.lang_type': LangRec.LATIN,
    },
    **{
        f'v6-{size}': {
            'Det.ocr_version': OCRVersion.PPOCRV6,
            'Det.model_type': ModelType(size),
            'Det.lang_type': 'it',
            'Rec.ocr_version': OCRVersion.PPOCRV6,
            'Rec.model_type': ModelType(size),
            'Rec.lang_type': 'it',
        }
        for size in ('tiny', 'small', 'medium')
    },
}

IMAGE = re.compile(r'^(.+?)(?:\.p(\d+))?\.(jpe?g|png|webp|bmp)$', re.I)


def page(result, width, height):
    """One OcrPage: a box (and its slant) per detected text line."""
    lines = []
    for quad, text in zip(result.boxes if result.boxes is not None else [],
                          result.txts or []):
        xs = [float(p[0]) for p in quad]
        ys = [float(p[1]) for p in quad]
        (x0, y0), (x1, y1), (x2, y2), (x3, y3) = [(float(a), float(b)) for a, b in quad]
        # The box handed to RowBuilder keeps the real text height (left and
        # right edges of the slanted quad) around the quad's centre. The
        # upright rectangle around a long slanted line would be as tall as
        # two rows, and RowBuilder would merge them.
        height = (math.dist((x0, y0), (x3, y3)) + math.dist((x1, y1), (x2, y2))) / 2
        cy = sum(ys) / 4
        lines.append({
            'text': text,
            'box': {'left': min(xs), 'top': cy - height / 2,
                    'right': max(xs), 'bottom': cy + height / 2},
            # Slant of the top edge in degrees, clockwise-positive like ML Kit.
            'angle': math.degrees(math.atan2(float(y1) - float(y0), float(x1) - float(x0))),
        })
    return {'width': float(width), 'height': float(height), 'lines': lines}


def main():
    parser = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    parser.add_argument('--model', default='v5-mobile', choices=sorted(MODELS))
    parser.add_argument('--photos', nargs='*',
                        default=['data/scontrini_foto_reali', 'data/foto_render'])
    parser.add_argument('--out')
    parser.add_argument('--refresh', action='store_true')
    args = parser.parse_args()

    out = Path(args.out or f'data/ocr_cache/paddle_{args.model}')
    out.mkdir(parents=True, exist_ok=True)

    receipts = {}
    for folder in args.photos:
        for f in sorted(Path(folder).glob('*')):
            m = IMAGE.match(f.name)
            if m:
                receipts.setdefault(m[1], []).append((int(m[2] or 0), f))

    engine = RapidOCR(params=MODELS[args.model])
    for name, pages in sorted(receipts.items()):
        target = out / f'{name}.ocr.json'
        if target.exists() and not args.refresh:
            continue
        started = time.perf_counter()
        doc = {'source': 'ocr', 'pages': []}
        for _, path in sorted(pages):
            import cv2  # bundled with rapidocr
            image = cv2.imread(str(path))
            if image is None:
                print(f'cannot read {path}', file=sys.stderr)
                continue
            doc['pages'].append(page(engine(image), image.shape[1], image.shape[0]))
        target.write_text(json.dumps(doc, ensure_ascii=False), encoding='utf-8')
        lines = sum(len(p['lines']) for p in doc['pages'])
        print(f'{name:<34} {lines:>4} lines {time.perf_counter() - started:>6.2f} s')


if __name__ == '__main__':
    main()
