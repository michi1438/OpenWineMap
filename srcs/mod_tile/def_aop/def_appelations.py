#!/bin/python3
import psycopg2
import sys 
from psycopg2.sql import SQL, Identifier
import os 

class bcolors:
    HEADER = '\033[95m'
    OKBLUE = '\033[94m'
    OKCYAN = '\033[96m'
    OKGREEN = '\033[92m'
    WARNING = '\033[93m'
    FAIL = '\033[91m'
    ENDC = '\033[0m'
    BOLD = '\033[1m'
    UNDERLINE = '\033[4m'

def main():
    try:

        connection = psycopg2.connect(
            database=os.environ['DB_NAME'],
            user=os.environ['DB_USER'],
            password=os.environ['DB_USER_PW'],
            host=os.environ['DB_HOST'],
            port=os.environ['DB_PORT']
        )
        cursor = connection.cursor()

        _data = os.listdir("/home/" + os.environ["DB_USER"] + "/db_connect/") 

        for n in _data: 
            if n.find("_data") > 1:
                print(bcolors.OKCYAN + f"\nREGION {n.upper()} #################################" + bcolors.ENDC)
                reg = n[:-5] 
                aoc_data = open("./" + n, "r")
                line = aoc_data.readline()
                while line: 
                    if line.strip().find("[AOP]") == 0:
                        aop = f'"{line[5:].strip()}"'
                        print ("aop = ", aop)
                    elif line.strip().find("[BORDER_SZ]") == 0:
                        border_sz = line[11:].strip()
                        print ("border_sz = ", border_sz)
                    elif line.find("{{\n") == 0:
                        create_aop(reg, cursor, aop, border_sz, aoc_data)
                    line = aoc_data.readline()
                aoc_data.close()
                connection.commit()

    except Exception as e:
        print(f"An error occurred: {e}")

def create_aop(reg, cursor, aop, border_sz, aoc_data):
    cursor.execute(SQL("DROP TABLE IF EXISTS {};").format(Identifier(aop)))
    cursor.execute(SQL("CREATE TABLE {} AS SELECT * FROM polygons WHERE 1 <> 1;").format(Identifier(aop)))
    off_aop = "AOP_" + aop[1:-1]
    line = aoc_data.readline()
    while line.find("}}\n") != 0:
        if line.strip().find("dep=") == 0:
            dep = line[4:].strip().split()
            print ("dep =", dep)
        elif line.strip().find("communes=") == 0:
            communes = line[9:].strip().split(',')
            print ("communes =", communes)
            cursor.execute("""SELECT * FROM commune_not_found(%(comm)s, %(dep)s);""", {'comm': communes, 'dep': dep})
            records = cursor.fetchall()
            if len(records) != 0: 
                print(bcolors.WARNING + "\nCOMMUNES NOT FOUND: FOR DEPARTEMENT", dep[0] + bcolors.ENDC)
                for row in records:
                   print(row)
            exec_var = {'comm': communes, 'dep': dep, 'border_sz':border_sz, 'off_aop': off_aop, 'reg': reg} 
            sql_statement = SQL("INSERT INTO {} SELECT * FROM polygons WHERE (name = ANY(%(comm)s) OR official_name = ANY(%(comm)s)) AND postal_code = ANY(%(dep)s);").format(Identifier(aop))
            cursor.execute(sql_statement, exec_var)
        line = aoc_data.readline()
    sql_statement = SQL("INSERT INTO {aop} (name, reg, official_name, geom, zaxis) VALUES ('the_whole_appelation', %(reg)s, %(off_aop)s, (SELECT st_simplify(ST_union(geom), 500) FROM {aop}), %(border_sz)s);").format(
            aop=Identifier(aop))
    cursor.execute(sql_statement, exec_var)
    print ("THE APPELATION", aop.upper(), "WAS CREATED !!\n")
    #cursor.execute(SQL("SELECT name,official_name,postal_code FROM {};").format(Identifier(aop)))
    #records = cursor.fetchall()
    #for row in records:
        #print(row)


if __name__=="__main__":
   main()
