# Receipt fixtures

Each fixture is a pair of files:

- `<name>.txt`: the receipt's rows as the row builder produces them, one printed row per line
- `<name>.expected.json`: the `ParsedReceipt` the parser should return (fields left out take their defaults)

`test/features/extraction/domain/receipt_parser_fixtures_test.dart` runs every pair in this folder.

`synthetic_*` fixtures are made up and follow common Italian layouts. Real receipts should replace
them over time. Before adding a real one, remove card numbers, loyalty card numbers and anything
else personal.
