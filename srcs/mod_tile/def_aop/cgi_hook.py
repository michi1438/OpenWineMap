#!/bin/python3                                                                                                                                                                                                                                                                                                                  
import cgitb                                                                                                                                                                                                                                                                                                                    
import cgi                                                                                                                                                                                                                                                                                                                      
import psycopg2
from psycopg2.sql import SQL, Identifier
import os 

def main():
    connection = psycopg2.connect(
        database=os.environ['DB_NAME'],
        user=os.environ['DB_USER'],
        password=os.environ['DB_USER_PW'],
        host=os.environ['DB_HOST'],
        port=os.environ['DB_PORT']
    )
    cursor = connection.cursor()

    cgitb.enable(display=0, logdir="/var/log/apache2/")                                                                                                                                                                                                                                                                             

    form = cgi.FieldStorage(environ={'REQUEST_METHOD':'POST'})                                                                                                                                                                                                                                                                      
    if "latlong" in form:
        popup_list(form, cursor)
    elif "appelation_name" in form: 
        appelation_bbox(form, cursor)

def popup_list(form, cursor):
    latlong = form["latlong"].value[7:-1].split(',')

    #cursor.execute("SELECT name from irouleguy limit 1;")
    cursor.execute(SQL("SELECT ST_AsText(ST_Transform(ST_GeomFromText('POINT({lat} {long})',4326),3857)) As wgs_geom;").format(
        lat=SQL(latlong[1]),
        long=SQL(latlong[0])))
    x = cursor.fetchone()[0]

    print("Content-Type: text/html;charset=utf-8")                                                                                                                                                                                                                                                                                  
    print ("Content-type:text/html\r\n")                                                                                                                                                                                                                                                                                            

    cursor.execute(SQL("SELECT name from ww_appelations where ST_Contains(geom, ST_GeomFromText('{point}', 3857))").format(
        point=SQL(x)))
    records = cursor.fetchall()
    for row in records:
        print(f"<p id=\"aop_name\" onmouseleave=\"hide_poly()\" onmouseenter=\"show_poly('" + str(row[0][4:].replace("'","\\'")) + f"')\"> \
                <a href=\"tech_sheet/{str(row[0])[4:]}.html\" target=\"split\" onclick=\"show_split('{str(row[0])[4:]}')\"> " \
                + str(row[0])[:4] + str(row[0])[4:].title() + "</a></p>")

def appelation_bbox(form, cursor):
    appl_name = "AOP_"
    appl_name += f'{form["appelation_name"].value}'

    #cursor.execute("SELECT name from irouleguy limit 1;")
    exec_var = {'aop_name': appl_name} 
    cursor.execute(SQL("SELECT ST_Extent(ST_FlipCoordinates(ST_Transform(ST_Envelope(geom), 4326))) FROM ww_appelations where name = %(aop_name)s"), exec_var)
    x = cursor.fetchone()[0].split(',')

    print("Content-Type: text/html;charset=utf-8")                                                                                                                                                                                                                                                                                  
    print ("Content-type:text/html\r\n")                                                                                                                                                                                                                                                                                            

    print(f"{x[0][4:]},{x[1][:-1]}")


if __name__=="__main__":
   main()
