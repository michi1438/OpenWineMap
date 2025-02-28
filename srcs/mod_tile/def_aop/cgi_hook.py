#!/bin/python3                                                                                                                                                                                                                                                                                                                  
import cgitb                                                                                                                                                                                                                                                                                                                    
import cgi                                                                                                                                                                                                                                                                                                                      
import psycopg2
from psycopg2.sql import SQL, Identifier
import os 
                                                                                                                                                                                                                                                                                                                                
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
latlong = form["latlong"].value[7:-1].split(',')

#cursor.execute("SELECT name from irouleguy limit 1;")
cursor.execute(SQL("SELECT ST_AsText(ST_Transform(ST_GeomFromText('POINT({lat} {long})',4326),3857)) As wgs_geom;").format(
    lat=SQL(latlong[1]),
    long=SQL(latlong[0])))
x = cursor.fetchone()[0]

print("Content-Type: text/html;charset=utf-8")                                                                                                                                                                                                                                                                                  
print ("Content-type:text/html\r\n")                                                                                                                                                                                                                                                                                            

_data = os.listdir("/home/" + os.environ["DB_USER"] + "/db_connect/") 
for n in _data: 
    if n.find("_data") > 1:
        aoc_data = open("/home/" + os.environ['DB_USER'] + f"/db_connect/{n}", "r")
        line = aoc_data.readline()
        while line: 
            if line.strip().find("[AOP]") == 0:
                aop = f'"{line[5:].strip()}"'
                cursor.execute(SQL("SELECT official_name from {aop} where name = 'the_whole_appelation' AND ST_Contains(geom, ST_GeomFromText('{point}', 3857))").format(
                    point=SQL(x),
                    aop=Identifier(aop)))
            line = aoc_data.readline()
            records = cursor.fetchall()
            for row in records:
                print(f"<p id=\"aop_name\" onmouseleave=\"hide_poly()\" onmouseenter=\"show_poly('{str(row[0])[4:]}')\">  <a href=\"tech_sheet/{str(row[0])[4:]}.html\" target=\"split\" onclick=\"show_split('{str(row[0])[4:]}')\"> " + str(row[0])[:4] + str(row[0])[4:].title() + "</a></p>")
