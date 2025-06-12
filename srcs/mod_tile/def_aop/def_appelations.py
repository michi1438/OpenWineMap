#!/bin/python3
import psycopg2
import sys 
import difflib
import shutil 
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
        
        #TODO For testing..
        cursor.execute(SQL("DROP TABLE IF EXISTS wine_types CASCADE;"))
        cursor.execute(SQL("DROP TABLE IF EXISTS grape_varieties CASCADE;"))
        cursor.execute(SQL("DROP TABLE IF EXISTS clim_n_geo CASCADE;"))
        cursor.execute(SQL("DROP TABLE IF EXISTS aop_types_grapes CASCADE;"))

        cursor.execute(SQL("CREATE TABLE IF NOT EXISTS wine_types(id serial PRIMARY KEY, name text NOT NULL UNIQUE, description text);"))
        cursor.execute(SQL("CREATE TABLE IF NOT EXISTS aop_types_grapes(aop_id int REFERENCES ww_appelations (id) ON UPDATE CASCADE ON DELETE CASCADE, type_id int[] , grp_prim_id int[], grp_seco_id int[]);"))
        cursor.execute(SQL("CREATE TABLE IF NOT EXISTS grape_varieties(id serial PRIMARY KEY, name text NOT NULL UNIQUE, description text);"))
        cursor.execute(SQL("CREATE TABLE IF NOT EXISTS clim_n_geo(id serial PRIMARY KEY, name text NOT NULL UNIQUE, description text);"))

        cursor.execute(SQL("DROP TABLE IF EXISTS ww_appelations CASCADE;"))
        cursor.execute(SQL("CREATE TABLE IF NOT EXISTS ww_appelations(id serial PRIMARY KEY, name text UNIQUE, reg text, geom geometry(Geometry,3857), zaxis smallint, postal_code text);"))

        if os.path.isdir('./prevData/') == False:
            os.mkdir("./prevData/")

        #TODO use that class
        class crt_aop_data:
            AOP = ''
            BORDER_SZ = 0
            VARIETY = None
            WINE_TYPES = []
            CLIM_n_GEO = None

        for n in _data: 
            if n.find("_data") > 1 and (os.path.isfile(f'./prevData/{n}') == False or file_r_equal(f'{n}', f'./prevData/{n}') == False):
                print(bcolors.OKCYAN + f"\nREGION {n.upper()} #################################" + bcolors.ENDC)
                
                reg = n[:-5] 
                aoc_data = open("./" + n, "r+")
                line = aoc_data.readline()
                cursor.execute(SQL("DROP VIEW IF EXISTS combined_table;"))
                ext_exists = False
                while line: 
                    if line.strip().find("[AOP]") == 0:
                        aop = f'"{line[5:].strip()}"'
                        print ("aop =", aop)
                    elif line.strip().find("[BORDER_SZ]") == 0:
                        border_sz = line[11:].strip()
                        print ("border_sz =", border_sz)
                    elif line.find("[VARIETY]") == 0:
                        create_var(line.strip(), cursor, aoc_data, aop)
                    elif line.find("[CLIM_n_GEO]") == 0:
                        create_climgeo(line.strip(), cursor, aoc_data)
                    elif line.find("{{\n") == 0:
                        create_aop(reg, cursor, aop, border_sz, aoc_data)
                    elif line.find("L.latLngBounds(") == 0:
                        ext_exists = True
                    line = aoc_data.readline()
                exec_var = {'reg': reg} 
                cursor.execute(SQL("select st_extent(st_flipcoordinates(st_transform(st_envelope(geom), 4326))) from ww_appelations WHERE reg = %(reg)s"), exec_var)
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
                shutil.copy2(f'./prevData/{n}',f'{n}')
                print(bcolors.OKCYAN + f"\nREGION {n.upper()} ALREADY IMPORTED (no change) #################################" + bcolors.ENDC)

    except Exception as e:
        print(f"An error occurred: {e}")
    print (bcolors.OKBLUE + "END " + __file__ + "\n" + bcolors.ENDC)

def create_var(variety, cursor, aoc_data, aop):
    varieties = variety[9:].split(',')
    off_aop = "AOP_" + aop[1:-1]
    
    print("CREATE_var: " + off_aop)
    for n in varieties:
        cursor.execute("""INSERT INTO wine_types (name) VALUES (%(var)s) ON CONFLICT DO NOTHING;""", {'var': n})
    line = aoc_data.readline()
    while line.find("}\n") != 0:
        seco = []
        line = line.strip()
        if line.find("prim=") == 0:
            prim = line[5:].split(',')
            for n in prim:
                cursor.execute("""INSERT INTO grape_varieties (name) VALUES(%(grp)s) ON CONFLICT DO NOTHING;""", {'grp': n})
            print(varieties)
        elif line.find("seco=") == 0: 
            seco = line[5:].split(',')
            for n in seco:
                cursor.execute("""INSERT INTO grape_varieties (name) VALUES(%(grp)s) ON CONFLICT DO NOTHING;""", {'grp': n})
        line = aoc_data.readline()
    cursor.execute("""INSERT INTO aop_types_grapes (aop_id, type_id, grp_prim_id, grp_seco_id) VALUES ((select id from ww_appelations where name = (%(aop_name)s)), (select array_agg(id) from wine_types where name = ANY(%(var)s)), (select array_agg(id) from grape_varieties where name = ANY(%(grp_prim)s)), (select array_agg(id) from grape_varieties where name = ANY(%(grp_seco)s))) ON CONFLICT DO NOTHING;""", {'var': varieties, 'aop_name': off_aop, 'grp_prim': prim, 'grp_seco':seco})

def create_climgeo(variety, cursor, aoc_data):
        climgeo_attr = variety[12:].split(',')
        for n in climgeo_attr:
            cursor.execute("""INSERT INTO clim_n_geo (name) VALUES(%(attr)s) ON CONFLICT DO NOTHING;""", {'attr': n})


def create_aop(reg, cursor, aop, border_sz, aoc_data):
    cursor.execute(SQL("DROP TABLE IF EXISTS {};").format(Identifier(aop)))
    dep_list = ""
    off_aop = "AOP_" + aop[1:-1]
    line = aoc_data.readline()
    all_id = []
    while line.find("}}") != 0:
        line = line.strip()
        if line.find("dep=") == 0:
            dep = line[4:].split()
            dep_list += dep[0] + ","
            print ("dep =", dep[0])
        elif line.find("communes=") == 0:
            communes = line[9:].split(',')
            print ("communes =", communes)
            cursor.execute("""SELECT * FROM commune_not_found(%(comm)s, %(dep)s);""", {'comm': communes, 'dep': dep})
            records = cursor.fetchall()
            if len(records) != 0: 
                print(bcolors.WARNING + "\nCOMMUNES NOT FOUND: FOR DEPARTEMENT", dep[0] + bcolors.ENDC)
                for row in records:
                    print(row)
            cursor.execute("""SELECT area_id FROM polygons WHERE (name = ANY(%(comm)s) OR official_name = ANY(%(comm)s)) AND postal_code = ANY(%(dep)s);""", {'comm': communes, 'dep': dep})
            records = cursor.fetchall()
            for row in records:
                all_id += row
        line = aoc_data.readline()
    print("all_area_id = ", all_id)

    exec_var = {'all_id': all_id, 'dep_list': dep_list, 'border_sz':border_sz, 'off_aop': off_aop, 'reg': reg} 
    sql_statement = SQL("INSERT INTO ww_appelations (name, reg, geom, zaxis, postal_code) VALUES (%(off_aop)s, %(reg)s, (SELECT st_simplify(ST_union(geom), 500) FROM polygons WHERE area_id = ANY(%(all_id)s)), %(border_sz)s, %(dep_list)s);").format(
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
