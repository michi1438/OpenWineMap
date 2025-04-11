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

def main():
    print(bcolors.OKBLUE + "RUNNING " + __file__ + bcolors.ENDC)
    lyr_renderd = open("/etc/renderd.conf", "a")
    _data = os.listdir("/home/" + os.environ["DB_USER"] + "/src/openstreetmap-carto/highlighted/") 
    leaf_list = ""
    for n in _data: 
        if n.find(".xml") > 1:
            lyr_renderd.writelines(["\n", f"[{n[:-4].lower()}]\n",
                f"URI=/tile/france/{n[:-4].lower()}/\n", # TODO add a var in futur for the country...
                "TILEDIR=/var/cache/renderd/tiles/\n",
                "XML=/home/" + os.environ["DB_USER"] + f"/src/openstreetmap-carto/highlighted/{n}\n",
                "HOST=localhost\n",
                "TILESIZE=256\n",
                "MAXZOOM=20\n"])
            print_debug(f"[{n[:-4]}] Highlight Layer was added to renderd.conf !")

            for line in fileinput.FileInput("/etc/apache2/sites-available/000-default.conf", inplace=True):
                if line.find("#AddHighlightedTileConfigs") >= 0:
                    line += f"\tAddTileConfig /tile/france/{n[:-4].lower()}/ {n[:-4].lower()}" + os.linesep
                print(line, end="")
            print_debug(f"Added the lines for both {n[:-4].lower()} and {n[:-4].lower()}_brd in the apache site config\n")

    print(bcolors.OKCYAN + "Added Highlight modifications to : #########################\n\t- /etc/renderd.conf\n\t- /etc/apache2/sites-available/000-default.conf\n" + bcolors.ENDC)

    lyr_renderd.close()    
    print (bcolors.OKBLUE + "END " + __file__ + "\n" + bcolors.ENDC)

def print_debug(str_debug):
    if "PY_SCRIPT_DEBUG" in os.environ and os.environ["PY_SCRIPT_DEBUG"] == "all":
        print(str_debug)

if __name__=="__main__":
   main()
