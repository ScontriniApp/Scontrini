# Receipt fixtures

Each fixture is a pair of files:

- `<name>.txt`: the receipt's rows as the row builder produces them, one printed row per line
- `<name>.expected.json`: the `ParsedReceipt` the parser should return (fields left out take their defaults)

`test/features/extraction/domain/receipt_parser_fixtures_test.dart` runs every pair in this folder.

A `.txt` without a matching `.expected.json` is skipped.

## Adding a real receipt

1. In a debug build (`flutter run`), capture the receipt and tap the bug icon ("Esporta come test")
   on the result screen.
2. With the phone on USB, run `tool/pull_fixtures.sh`. The files land in `incoming/`, which is
   git-ignored: `<name>.txt` (rows), `<name>.ocr.json` (raw OCR with positions) and
   `<name>.draft.json` (what the parser read).
3. Remove personal data from the `.txt`: card numbers, loyalty card numbers, names.
4. Fix the mistakes in the draft and save it as `<name>.expected.json`. Keep only the fields that
   differ from the defaults.
5. Move `<name>.txt` and `<name>.expected.json` into this folder, give them a descriptive name
   (e.g. `coop_weighed_items`), and run `flutter test`. A failing fixture is a parser bug to fix.

`synthetic_*` fixtures are made up and follow common Italian layouts. Real receipts should replace
them over time. Before adding a real one, remove card numbers, loyalty card numbers and anything
else personal.
