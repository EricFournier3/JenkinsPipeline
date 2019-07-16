import sys
import os
import subprocess
import yaml

"""
Eric Fournier 2019-07-12

Verifier la disponibilite et obtenir le genome de reference pour l analyse CoreSNV

"""

run_path,project_path,jenkins_param,organism, request= sys.argv[1:6]


def CheckRef():
    pass
    try:
        check = organism_dict[organism]
        #print check
    except:
        print "error"
        exit(1)

def GetRef():
    pass
    return ' '.join([organism_dict[organism],all_dict["coresnv_ref_path"]])

jenkins_param_handle = open(jenkins_param)
all_dict = yaml.load(jenkins_param_handle)
organism_dict = all_dict['coresnv_ref'][0]

if (request == "check"):
    CheckRef()
elif (request == "get"):
    pass
    print GetRef()

#path_to_ref_file = all_dict["coresnv_ref_path"]

jenkins_param_handle.close()
