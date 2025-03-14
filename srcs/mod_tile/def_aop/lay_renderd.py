#!/bin/python3                                                                                                                                                                                                                                                                                                                  
import os, fileinput

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

lyr_renderd = open("/etc/renderd.conf", "a")
_data = os.listdir("/home/" + os.environ["DB_USER"] + "/db_connect/") 
leaf_list = ""
lay_bnds = ""
for n in _data: 
    if n.find("_data") > 1:
        lyr_renderd.writelines(["\n", f"[{n[:-5].lower()}]\n",
            f"URI=/tile/france/{n[:-5].lower()}/\n", # TODO add a var in futur for the country...
            "TILEDIR=/var/cache/renderd/tiles/\n",
            f"XML=/home/owmuser/src/openstreetmap-carto/{n[:-5]}.xml\n",
            "HOST=localhost\n",
            "TILESIZE=256\n",
            "MAXZOOM=20\n"])
        print(f"[{n[:-5]}] Layer was added to renderd.conf !\n")
        lyr_renderd.writelines(["\n", f"[{n[:-5].lower()}_brd]\n",
            f"URI=/tile/france/{n[:-5].lower()}_brd/\n", # TODO add a var in futur for the country...
            "TILEDIR=/var/cache/renderd/tiles/\n",
            f"XML=/home/owmuser/src/openstreetmap-carto/{n[:-5]}_brd.xml\n",
            "HOST=localhost\n",
            "TILESIZE=256\n",
            "MAXZOOM=20\n"])
        print(f"[{n[:-5]}_brd] Layer was added to renderd.conf !\n")

        for line in fileinput.FileInput("/etc/apache2/sites-available/000-default.conf", inplace=True):
            if line.find("#AddTileConfigs") >= 0:
                line += f"\tAddTileConfig /tile/france/{n[:-5].lower()}/ {n[:-5].lower()}" + os.linesep
                line += f"\tAddTileConfig /tile/france/{n[:-5].lower()}_brd/ {n[:-5].lower()}_brd" + os.linesep
            print(line, end="")
        print(f"Added the lines for both {n[:-5].lower()} and {n[:-5].lower()}_brd in the apache site config\n")

        for line in fileinput.FileInput("/var/www/html/index.html", inplace=True):
            if line.find("// ADD the OWM tiles") >= 0:
                line += f"\t\t\tvar {n[:-5]} = L.tileLayer('/tile/france/{n[:-5].lower()}/{{z}}/{{x}}/{{y}}.png', {{" + os.linesep
                line += f"\t\t\t\tmaxZoom: 18," + os.linesep
                line += f"\t\t\t\tminZoom: 5," + os.linesep
                line += f"\t\t\t\topacity: 0.5," + os.linesep
                line += f"\t\t\t\tid: 'OWM'" + os.linesep
                line += f"\t\t\t}});" + os.linesep
                line += f"\t\t\tvar {n[:-5]}_brd = L.tileLayer('/tile/france/{n[:-5].lower()}_brd/{{z}}/{{x}}/{{y}}.png', {{" + os.linesep
                line += f"\t\t\t\tmaxZoom: 18," + os.linesep
                line += f"\t\t\t\tminZoom: 11," + os.linesep
                line += f"\t\t\t\tid: 'OWM'" + os.linesep
                line += f"\t\t\t}});" + os.linesep
                leaf_list += f", {n[:-5]}, {n[:-5]}_brd"
            if line.find("const addLayers = { //ADD the layer_list") >= 0:
                line += f"\t\t\t\t'{n[:-5]}': {n[:-5]}," + os.linesep
                line += f"\t\t\t\t'{n[:-5]}_brd': {n[:-5]}_brd," + os.linesep
            print(line, end="")
        print(f"Added the leaflet index.html js\n")
        aoc_data = open(f"/home/" + os.environ['DB_USER'] + "/db_connect/" + n, "r+")
        line = aoc_data.readline()
        while line: 
            if line.strip().find("L.latLngBounds") == 0:
                lay_bnds += line.strip() + ','
                lay_bnds += line.strip() + ','
            line = aoc_data.readline()
        aoc_data.close()

for line in fileinput.FileInput("/var/www/html/index.html", inplace=True):
    if line.find("// ADD leaflist") >= 0:
        line += f"\t\t\tvar map = L.map('map', {{layers: [osm{leaf_list}]}}).setView({{lon: 2.7, lat: 46.6}}, 5);" + os.linesep
    if line.find("// ADD lay_list") >= 0:
        line += f"\t\t\tvar lay_list = [{leaf_list[1:]}];" + os.linesep
    if line.find("// ADD lay_bounds") >= 0:
        line += f"\t\t\tvar lay_bounds = [{lay_bnds[:-1]}];" + os.linesep
    print(line, end="")
print(f"Added the leaflist to index js\n")

print(bcolors.OKCYAN + "Added modifications to : #########################\n\t- /etc/renderd.conf\n\t- /etc/apache2/sites-available/000-default.conf\n\t- /var/wwww/html/index.html\n" + bcolors.ENDC)

lyr_renderd.close()    
