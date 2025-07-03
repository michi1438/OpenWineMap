#!/bin/python3                                                                                                                                                                                                                                                                                                                  
import cgitb                                                                                                                                                                                                                                                                                                                    
import cgi                                                                                                                                                                                                                                                                                                                      
import psycopg2
from psycopg2.sql import SQL, Identifier
import os 
import shutil

def main():

    cgitb.enable(display=0, logdir="/var/log/apache2/")                                                                                                                                                                                                                                                                             

    param = cgi.FieldStorage()                                                                                                                                                                                                                                                                      
    if param["tech_sheet"]:
        parse(param)

def wait_for(file, status):
    print("Content-Type: text/html;charset=utf-8")                                                                                                                                                                                                                                                                                  
    print("Status: 302 Found")
    print("File_status: " + status)
    print("Location: /tech_sheet/." + file + ".html\r\n")

    print(f"<p> WAIT FOR IT.... /tech_sheet/." + file + ".html is comming ! </p>")
    print("\r\n\r\n")
    EXIt()

def parse(param):

    file = param["tech_sheet"].value #TODO try to hack... should be easy ! 
    if os.path.exists("/var/www/html/tech_sheet/." + file + ".html"):
        with open("/var/www/html/tech_sheet/." + file + ".html") as f:
            if "[[[" in f.read():
                os.remove("/var/www/html/tech_sheet/." + file + ".html");
                create_tech_sheet(file)
                wait_for(file, "RECREATED")
                return
        wait_for(file, "ALREADY_EXISTS")
        return
    else:
        create_tech_sheet(file)
        wait_for(file, "CREATED")

def create_tech_sheet(file):

    connection = psycopg2.connect(
        database=os.environ['DB_NAME'],
        user=os.environ['DB_USER'],
        password=os.environ['DB_USER_PW'],
        host=os.environ['DB_HOST'],
        port=os.environ['DB_PORT']
    )
    cursor = connection.cursor()
    
    appl_name = "AOP_" + file

    exec_var = {'aop_name': appl_name} 

    shutil.copyfile("/var/www/html/tech_sheet/base_tech_sheet.html", "/var/www/html/tech_sheet/." + file + ".html") 

    with open("/var/www/html/tech_sheet/." + file + ".html", 'r') as o_file:
        data = o_file.read()

    cursor.execute(SQL("SELECT name,id FROM ww_appelations where name = %(aop_name)s"), exec_var)
    name_id = cursor.fetchone()
    if name_id:
        data = data.replace('[[[APPL_NAME]]]', name_id[0].title())

        cursor.execute(SQL("SELECT type_id FROM aop_types_grapes where aop_id = %(id)s"), {'id': name_id[1]})
        x = cursor.fetchall()
        types = ""
        Grapes = ""
        for t in x:
            cursor.execute(SQL("SELECT array_agg(name) FROM wine_types where id = ANY(%(id)s)"), {'id': t})
            x = cursor.fetchone()
            types += str(x[0])[1:-1].replace("'","") + ", "
            for wt in t:
                cursor.execute(SQL("SELECT grp_prim_id FROM aop_types_grapes WHERE aop_id = %(id)s AND type_id = %(t_id)s" ), {'id': name_id[1], 't_id': wt})
                Grapes += "<h3>" + str(x[0])[2:-2].replace("'", "").title() + " Wines</h3>"
                xx = cursor.fetchone()
                cursor.execute(SQL("SELECT array_agg(name) FROM grape_varieties where id = ANY(%(id)s)"), {'id': xx})
                x = cursor.fetchone()
                Grapes +="<p><pre>Primary:    " + str(x[0])[2:-2].replace("'", "") + "</pre></p>\n"
                cursor.execute(SQL("SELECT grp_seco_id FROM aop_types_grapes WHERE aop_id = %(id)s AND type_id = %(t_id)s" ), {'id': name_id[1], 't_id': wt})
                xx = cursor.fetchone()
                cursor.execute(SQL("SELECT array_agg(name) FROM grape_varieties where id = ANY(%(id)s)"), {'id': xx})
                x = cursor.fetchone()
                if x[0]:
                    Grapes +="<p><pre>Secondary:  " + str(x[0])[2:-2].replace("'", "") + "</pre></p>\n"

        data = data.replace('[[[GRAPES]]]', str(Grapes))
        data = data.replace('[[[WINE_TYPES]]]', str(types[:-2]))

        cursor.execute(SQL("SELECT name,reg FROM ww_appelations where id = %(id)s"), {'id': name_id[1]})
        x = cursor.fetchone()
        if x:
            reg_full = str(x[0])[4:].title() + ", " + str(x[1]) + ", FRANCE";
            data = data.replace('[[[REGION]]]', reg_full)

    with open("/var/www/html/tech_sheet/." + file + ".html", 'w') as o_file:
        o_file.write(data)
    return

if __name__=="__main__":
   main()
