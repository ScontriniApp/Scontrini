"""Turns the Italian receipts of the synthetic-receipts-ocr dataset into a
benchmark set: photos plus ground truth in the bench's own format.

Dataset: huggingface.co/datasets/albertobarnabo/synthetic-receipts-ocr
(Apache-2.0). Synthetic receipts rendered and degraded like phone photos
(perspective, lighting, blur, noise, thermal fade, JPEG). The layout is made
up ("SCONTRINO", "DI CUI IVA"), so this set measures how well an OCR engine
reads damaged photos, not how well the parser knows real Italian stores:
never tune the parser to it.

Usage (needs pyarrow in the venv):
    .tooling/paddle-venv/Scripts/python -I tool/bench/import_synthetic.py \
        data/dataset_sintetico/eval-00000-of-00002.parquet [--out DIR] [--limit N]

Writes, under --out (default data/dataset_sintetico):
    foto/<id>.jpg                     the degraded photo
    ground_truth/<id>.rows.txt        printed rows (full_text, spaces collapsed)
    ground_truth/<id>.truth.json      ParsedReceipt-shaped answers
Per-item VAT is not printed on these receipts, so vatPercent is left out.
"""
import argparse
import json
import re
from datetime import datetime
from pathlib import Path

import pyarrow.parquet as pq


def cents(value):
    return round(value * 100)


def truth_of(fields):
    items = []
    for line in fields['lines']:
        item = {'rawName': line['name']}
        if line['qty'] != 1:
            item['quantity'] = line['qty']
        item['unitPriceCents'] = cents(line['unit_price'])
        item['lineTotalCents'] = cents(line['total'])
        items.append(item)
    date = datetime.strptime(f"{fields['date']} {fields['time']}", '%d/%m/%Y %H:%M')
    truth = {
        'storeName': fields['merchant'].upper(),
        'address': fields['address'].upper(),
        'purchaseDate': date.strftime('%Y-%m-%dT%H:%M:%S.000'),
        'totalCents': cents(fields['total']),
        'items': items,
        'notes': 'synthetic (synthetic-receipts-ocr); no per-item VAT printed',
    }
    if fields.get('tax_id'):
        truth['vatNumber'] = re.sub(r'\D', '', fields['tax_id'])
    return truth


def main():
    parser = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    parser.add_argument('parquet')
    parser.add_argument('--out', default='data/dataset_sintetico')
    parser.add_argument('--limit', type=int)
    args = parser.parse_args()

    out = Path(args.out)
    photos = out / 'foto'
    truth_dir = out / 'ground_truth'
    photos.mkdir(parents=True, exist_ok=True)
    truth_dir.mkdir(parents=True, exist_ok=True)

    table = pq.read_table(
        args.parquet,
        columns=['id', 'image_photo', 'full_text', 'fields', 'degradations'],
        filters=[('locale', '=', 'IT')],
    )
    rows = table.to_pylist()[: args.limit]
    for row in rows:
        name = row['id']
        (photos / f'{name}.jpg').write_bytes(row['image_photo']['bytes'])
        printed = [re.sub(r'\s+', ' ', l).strip() for l in row['full_text'].splitlines()]
        (truth_dir / f'{name}.rows.txt').write_text(
            '\n'.join(l for l in printed if l) + '\n', encoding='utf-8')
        truth = truth_of(json.loads(row['fields']))
        truth['notes'] += f"; degradations: {row['degradations']}"
        (truth_dir / f'{name}.truth.json').write_text(
            json.dumps(truth, indent=2, ensure_ascii=False) + '\n', encoding='utf-8')
    print(f'{len(rows)} Italian receipts -> {photos} and {truth_dir}')


if __name__ == '__main__':
    main()
