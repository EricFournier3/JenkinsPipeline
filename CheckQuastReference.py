import sys
import os
import subprocess
import yaml

"""
Eric Fournier 2019-08-15

Verifier la disponibilite et obtenir le genome de reference pour Quast

"""

run_path,project_path,jenkins_param,organism= sys.argv[1:5]

def GetRef():

    try:
        check = organism_dict[organism]
        return ' '.join([organism_dict[organism][0],organism_dict[organism][1], all_dict["quast_ref_path"]])
    except:
        return ''

jenkins_param_handle = open(jenkins_param)
all_dict = yaml.load(jenkins_param_handle)
organism_dict = all_dict['quast_ref'][0]

print GetRef()

jenkins_param_handle.close()