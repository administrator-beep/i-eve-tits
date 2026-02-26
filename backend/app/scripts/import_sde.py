import os
import glob
import json
from sqlalchemy import text
from ..db import engine
import json

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), '..', '..', '..', '..'))
DATA_DIR = os.path.join(ROOT, 'eve-static-data')
if not os.path.isdir(DATA_DIR):
    DATA_DIR = os.path.join(ROOT, '..', 'eve-static-data')


def import_all():
    files = glob.glob(os.path.join(DATA_DIR, '*.jsonl'))
    print(f"Found {len(files)} files to import")

    for fp in files:
        name = os.path.basename(fp).replace('.jsonl', '')
        table = f'sde_{name}'
        print(f"Importing {name} -> {table}")

        # create table (Postgres JSONB if available)
        try:
            with engine.begin() as conn:
                # detect dialect
                dialect = engine.dialect.name
                if dialect == 'postgresql':
                    conn.execute(text(f"CREATE TABLE IF NOT EXISTS {table} (id serial PRIMARY KEY, data jsonb);"))
                else:
                    conn.execute(text(f"CREATE TABLE IF NOT EXISTS {table} (id INTEGER PRIMARY KEY AUTOINCREMENT, data TEXT);"))

                batch = []
                with open(fp, 'r', encoding='utf-8') as f:
                    for line in f:
                        line = line.strip()
                        if not line:
                            continue
                        obj = json.loads(line)
                        if obj.get('_key') == 'sde':
                            continue
                        if dialect == 'postgresql':
                            batch.append((json.dumps(obj),))
                        else:
                            batch.append((json.dumps(obj),))

                        if len(batch) >= 1000:
                            if dialect == 'postgresql':
                                conn.execute(text(f"INSERT INTO {table} (data) VALUES (CAST(:data AS jsonb))"), [{'data':b[0]} for b in batch])
                            else:
                                conn.execute(text(f"INSERT INTO {table} (data) VALUES (:data)"), [{'data':b[0]} for b in batch])
                            batch = []

                if batch:
                    if dialect == 'postgresql':
                        conn.execute(text(f"INSERT INTO {table} (data) VALUES (:data)"), [{'data':b[0]} for b in batch])
                    else:
                        conn.execute(text(f"INSERT INTO {table} (data) VALUES (:data)"), [{'data':b[0]} for b in batch])
                print(f"  imported {table}")
        except Exception as e:
            print(f"Error importing {name}: {e}")


def normalize_types():
    # read raw file and create normalized types table
    fp = None
    candidates = [os.path.join(DATA_DIR, 'types.jsonl'), os.path.join(DATA_DIR, 'typeMaterials.jsonl')]
    if os.path.exists(candidates[0]):
        fp = candidates[0]
    if not fp:
        print('types.jsonl not found, skipping types normalization')
        return

    table = 'sde_types_norm'
    with engine.begin() as conn:
        conn.execute(text(f"CREATE TABLE IF NOT EXISTS {table} (type_id bigint PRIMARY KEY, name text, group_id integer, market_group_id integer, volume numeric, portion_size integer, base_price numeric, data jsonb);") )
        with open(fp, 'r', encoding='utf-8') as f:
            batch = []
            for line in f:
                obj = json.loads(line)
                if obj.get('_key') == 'sde':
                    continue
                type_id = int(obj.get('typeID', obj.get('id') or 0))
                name = obj.get('name', '')
                group_id = obj.get('groupID') or obj.get('group_id')
                market_group_id = obj.get('marketGroupID') or obj.get('market_group_id')
                volume = obj.get('volume')
                portion = obj.get('portionSize') or obj.get('portion_size')
                base_price = obj.get('basePrice') or obj.get('base_price')
                conn.execute(text(f"INSERT INTO {table} (type_id,name,group_id,market_group_id,volume,portion_size,base_price,data) VALUES (:tid,:name,:gid,:mgid,:vol,:ps,:bp,CAST(:data AS jsonb)) ON CONFLICT (type_id) DO NOTHING"),
                             {'tid': type_id, 'name': name, 'gid': group_id, 'mgid': market_group_id, 'vol': volume, 'ps': portion, 'bp': base_price, 'data': json.dumps(obj)})
    print('Normalized types into', table)


def normalize_groups():
    fp = os.path.join(DATA_DIR, 'groups.jsonl')
    if not os.path.exists(fp):
        print('groups.jsonl not found, skipping groups normalization')
        return
    table = 'sde_groups_norm'
    with engine.begin() as conn:
        conn.execute(text(f"CREATE TABLE IF NOT EXISTS {table} (group_id integer PRIMARY KEY, name text, category_id integer, data jsonb);") )
        with open(fp, 'r', encoding='utf-8') as f:
            for line in f:
                obj = json.loads(line)
                if obj.get('_key') == 'sde':
                    continue
                gid = obj.get('groupID') or obj.get('id')
                name = obj.get('name')
                cat = obj.get('categoryID') or obj.get('category_id')
                conn.execute(text(f"INSERT INTO {table} (group_id,name,category_id,data) VALUES (:gid,:name,:cat,CAST(:data AS jsonb)) ON CONFLICT (group_id) DO NOTHING"),
                             {'gid': gid, 'name': name, 'cat': cat, 'data': json.dumps(obj)})
    print('Normalized groups into', table)


if __name__ == '__main__':
    import_all()
    try:
        normalize_types()
    except Exception as e:
        print('normalize_types error:', e)
    try:
        normalize_groups()
    except Exception as e:
        print('normalize_groups error:', e)
