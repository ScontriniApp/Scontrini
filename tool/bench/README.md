# Extraction benchmark

Scores the extraction pipeline (PDF/photo → rows → `ParsedReceipt` → category) against hand-checked
answers, without opening the app. It runs the app's own code (`PdfTextReader`, `MlKitOcr`,
`RowBuilder`, `ReceiptParser`), so a better score here is a better app.

## How to run

**On the PC (seconds, no phone):** PDFs, and photos whose ML Kit output was already saved.

```bash
flutter test tool/bench/desktop_bench_test.dart
```

Options as `--dart-define=NAME=value`: `BENCH_PDFS`, `BENCH_OCR`, `BENCH_TRUTH`, `BENCH_OUT`, and
`BENCH_ONLY=<text>` to run only the receipts whose name contains it. On Windows, load the project SDK
first (`. .\.tooling\env.ps1`).

**On a phone or emulator (ML Kit only runs on Android):** new photos, and scanned PDFs.

```bash
tool/bench/run_device.sh                                # photos in data/scontrini_foto_reali
tool/bench/run_device.sh --pdfs data/scontrini/scontrini # also the PDFs, through the app's PDF path
```

Keep the phone **unlocked with the screen on** during the run: with the screen locked Android sends
the app to the background and the test stops after a few seconds ("did not complete"). Add `-v` to
Flutter's output with `BENCH_FLUTTER_ARGS=-v` to debug a run.

It pushes the receipts and the answers to the app's folder on the device, runs
`integration_test/bench/device_bench_test.dart`, pulls the report, and deletes the receipts from the
device (`--keep` to leave them). The first run builds the app (~4 min); later runs take about a minute.

**ML Kit only once per photo.** Every device run saves ML Kit's output for each photo in
`data/ocr_cache/<name>.ocr.json`, and the PC run replays those files. Photos exported from the app on
a real phone ("Esporta come test" + `tool/pull_fixtures.sh`) are replayed the same way from
`assets/test_receipts/incoming/`. So work on the row builder and the parser happens on the PC only;
the device is needed again only for new photos or to test a different OCR setup.

**PaddleOCR on the phone and on the PC, with the app's own code.**

```bash
tool/bench/run_device.sh --paddle                       # the app's model (small, from the assets)
tool/bench/run_device.sh --paddle --paddle-size medium  # pushes data/modelli/paddle/*medium* first
```

Each receipt prints its time per step (decode, detection, boxes, crops, recognition) and memory;
the text lands in `data/ocr_cache/paddle_device-v6-<size>/`. On the PC,
`flutter test tool/bench/paddle_dart_test.dart --dart-define=PADDLE=true` runs the same Dart code
(`PaddleOcr`) on the bench photos into `data/ocr_cache/paddle_dart-v6-<size>/`: it must score like
`paddle_ocr.py`, which checks the port (onnxruntime from the Python venv, see the file's header).

**PaddleOCR on the PC (no device, same models as on Android).** `paddle_ocr.py` reads the photos
with PP-OCR ONNX models through RapidOCR and onnxruntime, the same runtime the app would use on
Android, so the score on the PC is the score on the phone:

```bash
python -m venv .tooling/paddle-venv                      # once, outside git
.tooling/paddle-venv/Scripts/python -m pip install rapidocr onnxruntime
.tooling/paddle-venv/Scripts/python tool/bench/paddle_ocr.py --model v6-medium   # or v5-mobile, v6-tiny, v6-small
flutter test tool/bench/desktop_bench_test.dart
```

Output goes to `data/ocr_cache/paddle_<model>/` (models are downloaded on first use into the venv)
and shows up as the group "photos · PaddleOCR <model>". The line boxes keep the real text height of
the slanted quad: the upright rectangle around a long slanted line made `RowBuilder` merge rows.

**Synthetic photo set (stress test for OCR engines).** No free dataset of real Italian receipt
photos exists, so `import_synthetic.py` turns the Italian receipts of
[synthetic-receipts-ocr](https://huggingface.co/datasets/albertobarnabo/synthetic-receipts-ocr)
(Apache-2.0; rendered receipts with perspective, lighting, blur, noise, thermal fade, JPEG) into a
separate bench set. Its layout is made up ("SCONTRINO", "DI CUI IVA", no per-item VAT): it measures
how an engine reads damaged photos, never tune the parser to it.

```bash
.tooling/paddle-venv/Scripts/python -m pip install pyarrow              # once
# download data/eval-00000-of-00002.parquet (128 MB, ~155 Italian receipts) into data/dataset_sintetico/
.tooling/paddle-venv/Scripts/python -I tool/bench/import_synthetic.py data/dataset_sintetico/eval-00000-of-00002.parquet
.tooling/paddle-venv/Scripts/python tool/bench/paddle_ocr.py --model v6-medium \
    --photos data/dataset_sintetico/foto --out data/dataset_sintetico/ocr_cache/paddle_v6-medium
flutter test tool/bench/desktop_bench_test.dart --dart-define=BENCH_PDFS=data/none \
    --dart-define=BENCH_OCR=data/dataset_sintetico/ocr_cache \
    --dart-define=BENCH_TRUTH=data/dataset_sintetico/ground_truth
```

## What it measures

One summary per group (PDF, photos · ML Kit, photos · PaddleOCR), printed and saved in full in
`data/bench_runs/`:

| Step | Measures | Against |
|---|---|---|
| 1 · text | rows found exactly, rows in the right order, character similarity | `<name>.rows.txt` |
| 2 · parsing | each header field, items found / invented / fully correct, wrong item fields, receipts that balance, perfect receipts | `<name>.truth.json` |
| 2 · clean rows | the same, with the parser fed `rows.txt`: parser errors only | `<name>.truth.json` |
| 3 · categories | answered / correct, on the expected item names | `category` in `truth.json` |

If "pipeline" is much worse than "clean rows", the problem is in text extraction or row building;
if both are bad, it is in the parser. Step 3 uses `src/keyword_classifier.dart` (the seed keywords)
as a baseline; another classifier only needs to be a `CategoryClassifier` function.
Receipts without an answer are still run, and their parser output in the report is a draft for a new
`truth.json`.

Code: `src/` holds the platform-free parts (case discovery, ground truth, scoring, report);
`desktop_bench_test.dart` and `integration_test/bench/device_bench_test.dart` only differ in how
they get the text. Scoring tests: `test/tool/bench/scoring_test.dart`.

## Folder layout (local only)

Everything under `data/` is git-ignored: real receipts contain loyalty card numbers and shopping
history. Only the benchmark code and this README are committed.

```
data/
├── scontrini/scontrini/<name>.pdf     PDF receipts
├── scontrini_foto_reali/<name>.jpg    photos; <name>.p1.jpg, <name>.p2.jpg for a receipt in parts
├── ground_truth/
│   ├── <name>.rows.txt                clean transcription of the printed receipt
│   └── <name>.truth.json              expected structured result
├── ocr_cache/<name>.ocr.json          ML Kit output saved by device runs
└── bench_runs/<timestamp>_<where>.json   one full report per run
```

`<name>` is the input file name without its extension, so the files pair up automatically. A photo
of a receipt that also exists as a PDF can reuse its answers by using the same name.

## `<name>.rows.txt`

One printed row per line, in visual order, columns joined by a single space (same style as
`assets/test_receipts/*.txt`). It covers the fiscal document only: from the store header down to
the date/document number. It leaves out the payment receipt, loyalty points and ads, so it never
contains card numbers. On PAM receipts the date lives in the footer, so the footer rows are kept.

Used for two things:
- **text score**: how many of these rows the PDF reader / OCR produced (fuzzy, whitespace-insensitive);
- **parser on clean input**: the parser runs on these rows directly, so a parser error can be told
  apart from a text-extraction error.

## `<name>.truth.json`

Same shape as `ParsedReceipt` (`lib/features/extraction/domain/models/parsed_receipt.dart`), so it
loads with `ParsedReceipt.fromJson`. Fields left out take their defaults. Extra keys are ignored by
`fromJson` and used only by the benchmark:

| Key | Where | Meaning |
|---|---|---|
| `category` | item | expected category, one of the names in `default_categories.dart` |
| `ignoredRows` | receipt | rows in the item section that are not items (e.g. `PUNTI FRAGOLA 20`) |
| `notes` | receipt | free text: layout quirks, guesses, open doubts |

Rules:
- Amounts are integer cents. Discounts are positive and attached to the item they follow
  (`discountCents`); `discountCents` on the receipt is only for discounts on the subtotal.
- Items minus discounts must equal `totalCents`.
- `rawName` is the product name as printed, without flag columns (PAM's leading `T`/`X`) or the
  VAT column.
- Pack sizes in the name (`X2`, `X 1`, `GR420`) are not quantities: `quantity` stays 1 unless the
  receipt prints a separate quantity or weight row.
- A product printed on two rows stays as two items.
- Bags and shoppers (0,01 / 0,10) are items, category `Altro`.
- Esselunga `BUONO SPESA x,xx-S` (always the last row before the total) is a voucher on the whole
  receipt: it goes in the receipt's `discountCents`. `Sconto APP` and `SC. 2X1` belong to the item above.
- Esselunga weighed items print `KG. <weight> <price per kg>` on the row *before* the item:
  `quantity` is the printed weight, `unit` is `kg`, `unitPriceCents` is the price per kg.
- VAT code `*NS` (not subject to VAT, e.g. newspapers) is still an item.
- `address` is upper case, as in the existing fixtures. `purchaseDate` is local time as printed.
