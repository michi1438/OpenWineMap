#!/bin/python3                                                                                                                                                                                                                                                                                                                  

import os, subprocess

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

_data = os.listdir("/home/" + os.environ["DB_USER"] + "/db_connect/") 
leaf_list = ""
subprocess.run(["make"]) 
for n in _data: 
    if n.find("_data") > 1:
        subprocess.run(["./poly_draw", n[:-5]])
        subprocess.run(["./brd_draw", n[:-5]])

print (bcolors.OKCYAN + "Done building the .xml file. ##############################" + bcolors.ENDC)
