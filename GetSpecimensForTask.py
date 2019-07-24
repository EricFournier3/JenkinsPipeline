import yaml
import sys
"""
Eric Fournier 2019-07-10
Choisir la liste de specimen a traiter selon l etape jenkins
"""

#Le fichier de parametre JenkinsParameter.yaml
jenkins_param = sys.argv[1]

#Le sample sheet des specimens de ce projet
sample_sheet = sys.argv[2]

#L etape Jenkins
step = sys.argv[3]

#print sys.argv[:]

#Les pipeline contenant le step
target_pipeline = []

jenkins_param_handle = open(jenkins_param)
all_dict = yaml.load(jenkins_param_handle)

#Les etapes de chacun des pipelines
jenkins_step_dict = all_dict["jenkins_step"][0]
#print jenkins_step_dict
jenkins_param_handle.close()

sample_sheet_handle = open(sample_sheet)
sample_sheet_handle.readline()

#Les specimens du projets et leur(s) pipeline(s) respectif(s)
all_spec_pipelines_tup = ()

for line in sample_sheet_handle:
    #print line,
    arr = line.split(',')
    spec_pipelines_tup =  ((arr[0], arr[9].split('-')),)
    all_spec_pipelines_tup = all_spec_pipelines_tup + spec_pipelines_tup
sample_sheet_handle.close()

#print dict(all_spec_pipelines_tup)

#Les pipelines qui contiennent ce step
for pipeline, steps in dict(jenkins_step_dict).items():
    #print pipeline, steps
    if step in steps:
        target_pipeline.append(pipeline)

#print target_pipeline

#Liste des specimens a traiter pour ce step
specs_for_step = []

for spec, pipelines in dict(all_spec_pipelines_tup).items():
    #print spec, pipelines
    intersec = set(pipelines) & set(target_pipeline)

    #Un specimen est ajoute a la liste finale si un de ces pipeline a executer contient le step
    if len(intersec) > 0:
        specs_for_step.append(spec)

print ' '.join(specs_for_step)
