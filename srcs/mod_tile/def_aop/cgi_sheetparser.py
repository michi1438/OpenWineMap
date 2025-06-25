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

def parse(param):

    #cursor.execute("SELECT name from irouleguy limit 1;")

    file = param["tech_sheet"].value #TODO try to hack... should be easy ! 
    if os.path.exists("/var/www/html/tech_sheet/." + file + ".html"):
        print("Status: 302 Found")
        print("Location: /tech_sheet/." + file + ".html")
        print()
        return
    else:
        print("Content-Type: text/html;charset=utf-8")                                                                                                                                                                                                                                                                                  
        print("Refresh: 10")
        print ("Content-type:text/html\r\n")                                                                                                                                                                                                                                                                                            

        print(f"<p> WAIT FOR IT.... /tech_sheet/." + file + ".html is comming ! </p>")
        create_tech_sheet(file)
        print()
        print("Status: 302 Found")
        print("Location: /tech_sheet/." + file + ".html")
        print()
        return
        
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
    y = cursor.fetchone()
    if y:
        print("y = ")
        print(y)
        print("\n")
        data = data.replace('[[[APPL_NAME]]]', y[0].title())

        cursor.execute(SQL("SELECT type_id FROM aop_types_grapes where aop_id = %(id)s"), {'id': y[1]})
        x = cursor.fetchall()
        types = ""
        for t in x:
            cursor.execute(SQL("SELECT array_agg(name) FROM wine_types where id = ANY(%(id)s)"), {'id': t})
            x = cursor.fetchone()
            types += str(x[0])[1:-1].replace("'","") + ", "
        print("types = ")
        print(types)
        print("\n")
        data = data.replace('[[[WINE_TYPES]]]', str(types[:-2]))
        cursor.execute(SQL("SELECT name,reg FROM ww_appelations where id = %(id)s"), {'id': y[1]})
        x = cursor.fetchone()
        if x:
            print("x = ")
            reg_full = str(x[0])[4:].title() + ", " + str(x[1]) + ", FRANCE";
            print(reg_full)
            print("\n")
            data = data.replace('[[[REGION]]]', reg_full)

    with open("/var/www/html/tech_sheet/." + file + ".html", 'w') as o_file:
        o_file.write(data)
    return

if __name__=="__main__":
   main()
