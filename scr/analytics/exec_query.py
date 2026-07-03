# %%
import argparse
import pandas as pd
import sqlalchemy
import datetime
from tqdm  import tqdm

# %% 

def import_query (path):
    with open(path) as open_file: 
        query = open_file.read()
    return query

def date_rage(start,stop): 
    dates = []
    while start <= stop: 
        dates.append(start)
        dt_start = datetime.datetime.strptime(start,'%Y-%m-%d') + datetime.timedelta(days=1)
        start = datetime.datetime.strftime(dt_start, '%Y-%m-%d')
    return dates


def exec_query(db_origin,table,db_target,start,stop):

    engine_app = sqlalchemy.create_engine(f"sqlite:///../../data/{db_origin}/database.db")
    engine_analytical = sqlalchemy.create_engine(f"sqlite:///../../data/{db_target}/database.db")
    dates = date_rage(f'{start}', f'{stop}')
    query = import_query(f'{table}.sql')

    for i in tqdm(dates):
        with engine_analytical.connect() as con:
            try: 
                query_delete = f"DELETE FROM {table} WHERE dtRef = ('{i}', '-1 day')"
                
                print(query_delete)
                con.execute(sqlalchemy.text(query_delete))
                con.commit()
            except Exception as err:
                print(err)

        print(i)
        query_format = query.format(date=i)
        df = pd.read_sql(query_format,engine_app)
        df.to_sql(table,engine_analytical,index = False,if_exists="append")

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--db_origin",choices=['loyalty-system','ed-platform'],default='loyalty-system')
    parser.add_argument("--db_target",choices=['analytics'],default='analytics')
    parser.add_argument("--table",type=str,help="Table that will be processed with the same name as the file")
    parser.add_argument("--start",type=str,default='2026-01-01',help="Table that will be processed with the same name as the file")
    stop = datetime.datetime.now().strftime('%Y-%m-%d')
    parser.add_argument("--stop",type=str,default=stop)
    args = parser.parse_args()
    exec_query(args.db_origin,args.table,args.db_target,args.start,args.stop)


if __name__ == '__main__':
    main()