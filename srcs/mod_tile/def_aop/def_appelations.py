#!/bin/python3
import psycopg2
import sys 
import difflib
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
    print(bcolors.OKBLUE + "RUNNING " + __file__ + bcolors.ENDC)
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

        if os.path.isdir('./prevData/') == False:
            os.mkdir("./prevData/")

        for n in _data: 
            if n.find("_data") > 1 and (os.path.isfile(f'./prevData/{n}') == False or file_r_equal(f'{n}', f'./prevData/{n}') == False):
                print(bcolors.OKCYAN + f"\nREGION {n.upper()} #################################" + bcolors.ENDC)
                reg = n[:-5] 
                aoc_data = open("./" + n, "r+")
                line = aoc_data.readline()
                aop_list = []
                cursor.execute(SQL("DROP VIEW IF EXISTS combined_table;"))
                ext_exists = False
                while line: 
                    if line.strip().find("[AOP]") == 0:
                        aop = f'"{line[5:].strip()}"'
                        aop_list.append(f"\"\"{aop}\"\"")
                        print ("aop = ", aop)
                    elif line.strip().find("[BORDER_SZ]") == 0:
                        border_sz = line[11:].strip()
                        print ("border_sz = ", border_sz)
                    elif line.find("{{\n") == 0:
                        create_aop(reg, cursor, aop, border_sz, aoc_data)
                    elif line.find("L.latLngBounds(") == 0:
                        ext_exists = True
                    line = aoc_data.readline()
                sql_view = ""
                for x in aop_list:
                    if sql_view == "":
                        sql_view = f"CREATE VIEW combined_table AS SELECT geom, name FROM {x} "
                    else:
                        sql_view += f"UNION ALL SELECT geom, name FROM {x} "
                sql_view +=";"
                cursor.execute(SQL(sql_view + "select st_extent(st_flipcoordinates(st_transform(st_envelope(geom), 4326))) from combined_table"))
                # L.latLngBounds(L.latLng(50.736455, -6.328125),L.latLng(40.553080, 9.843750))
                extent = cursor.fetchall()[0][0][3:]
                print ("extent of the region = " + extent) 
                ind = extent.find(",")
                ext_leaflet = "L.latLngBounds(L.latLng" + extent[:ind] + "),L.latLng(" + extent[extent.find(",") + 1:] + ")"
                if ext_exists == False:
                    aoc_data.write(ext_leaflet.replace(" ", ", ") + "\n")
                        
                aoc_data.close()
                connection.commit()
                
            elif n.find("_data") > 1:
                print(bcolors.OKCYAN + f"\nREGION {n.upper()} ALREADY IMPORTED (no change) #################################" + bcolors.ENDC)

    except Exception as e:
        print(f"An error occurred: {e}")
    print (bcolors.OKBLUE + "END " + __file__ + "\n" + bcolors.ENDC)

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

def file_r_equal(file1, file2):
    o_file1 = open(file1)
    o_file2 = open(file2)

    line_of_file1 = o_file1.readline()
    line_of_file2 = o_file2.readline()
    while line_of_file1 or line_of_file2:
        if line_of_file1 == line_of_file2 or (line_of_file2.find("L.latLngBounds(L.latLng") == 0 and line_of_file1 == ""):
            line_of_file1 = o_file1.readline()
            line_of_file2 = o_file2.readline()
        else: 
            o_file1.close()
            o_file2.close()
            return False
    o_file1.close()
    o_file2.close()
    return True
    

if __name__=="__main__":
   main()
