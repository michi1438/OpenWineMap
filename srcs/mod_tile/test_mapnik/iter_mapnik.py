#!/bin/python3                                                                                                                                                                                                                                                                                                                  

import os, subprocess
import shutil 

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
    print(bcolors.OKBLUE + "RUNNING " + __file__ + bcolors.ENDC, flush=True)
    subprocess.run(["make"]) 
    dbconn_path = "/home/" + os.environ["DB_USER"] + "/db_connect/"
    carto_path = "/home/" + os.environ["DB_USER"] + "/src/"
    _data = os.listdir(dbconn_path) 
    leaf_list = ""
    for n in _data: 
        if n.find("_data") > 1:
            if "PY_SCRIPT_DEBUG" in os.environ and os.environ["PY_SCRIPT_DEBUG"] == "all":
                debug_output(dbconn_path, carto_path, n) 
            if os.path.isfile(dbconn_path + f"openstreetmap-carto/{n[:-5]}.xml") == False or \
            os.path.isfile(dbconn_path + f"openstreetmap-carto/{n[:-5]}_brd.xml") == False or \
            file_r_equal(dbconn_path + f"{n}", dbconn_path + f"prevData/{n}") == False:
                subprocess.run(["./poly_draw.out", n[:-5]])
                subprocess.run(["./brd_draw.out", n[:-5]])
                subprocess.run(["./highlighted_draw.out", n[:-5]])
                shutil.copy2(dbconn_path + f'{n}', dbconn_path + f'./prevData/{n}') 
                print(bcolors.OKCYAN + f"\nREGION {n.upper()}.XML CREATED OR RECREATED #################################" + bcolors.ENDC)
            else:
                shutil.copy2(dbconn_path + f"openstreetmap-carto/{n[:-5]}.xml", carto_path + "openstreetmap-carto/")
                shutil.copy2(dbconn_path + f"openstreetmap-carto/{n[:-5]}_brd.xml", carto_path + "openstreetmap-carto/")
                if copy_highlighted(dbconn_path, carto_path, n) == False:
                    subprocess.run(["./highlighted_draw.out", n[:-5]])
                print(bcolors.OKCYAN + f"\nREGION {n.upper()}.XML ALREADY CREATED(no change) #################################" + bcolors.ENDC)
    print (bcolors.OKCYAN + "Done building the .xml file. ##############################" + bcolors.ENDC)
    shutil.copytree(carto_path + "openstreetmap-carto/", dbconn_path + "openstreetmap-carto/", dirs_exist_ok=True)
    print (bcolors.OKBLUE + "END " + __file__ + "\n" + bcolors.ENDC)

def file_r_equal(file1, file2):
    if os.path.isfile(file1) == False or os.path.isfile(file2) == False:
        return False
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

def debug_output(dbconn_path, carto_path, n):
    print(f"{n[:-5]}.xml exist : ")
    print(os.path.isfile(dbconn_path + f"openstreetmap-carto/{n[:-5]}.xml"))
    print(f"{n[:-5]}_brd.xml exist : ")
    print(os.path.isfile(dbconn_path + f"openstreetmap-carto/{n[:-5]}_brd.xml"))
    print(f"files {n} are equal : ")
    print(file_r_equal(dbconn_path + f"{n}", dbconn_path + f"prevData/{n}"))

def copy_highlighted(dbconn_path, carto_path, n):
    aoc_data = open(dbconn_path + n, "r+")
    line = aoc_data.readline()
    while line:
        if line.find("[AOP]") == 0:
            aop = f'{line[5:].strip()}'
            if os.path.isfile(dbconn_path + "openstreetmap-carto/highlighted/" + aop + ".xml") == False:
                aoc_data.close()
                return False 
            shutil.copy2(dbconn_path + "openstreetmap-carto/highlighted/" + aop + ".xml", carto_path + "openstreetmap-carto/highlighted/")
        line = aoc_data.readline()
    aoc_data.close()
    return True

if __name__=="__main__":
   main()
