
import yaml
import sys
"""
Eric Fournier 2019-06-17
Retourne des valeurs de parametre a partir du fichier yaml snakemake_param
"""

snakemake_param = sys.argv[1]
mykey= sys.argv[2]

sample_sheet = None
sample_sheet_handle = None
pipeline_from_samplesheet = None

snakemake_param_handle = open(snakemake_param)

all_dict = yaml.load(snakemake_param_handle)
snakemake_file_dict = all_dict["snakemake_file"][0]
snakemake_rules_dict = all_dict["snakemake_rules"][0]
organism_dict = all_dict["organism"][0]
genome_length_file = all_dict["GenomeLengthFile"]

snakemake_param_handle.close()


if mykey == "snakemake_files":
    sample_sheet = sys.argv[3]
    sample_sheet_handle = open(sample_sheet)
    header = sample_sheet_handle.readline()
    pipeline_from_samplesheet = sample_sheet_handle.readline().split(',')[9]
    sample_sheet_handle.close()
    file_list = snakemake_file_dict[pipeline_from_samplesheet]
    #print len(file_list)
    print ' '.join(file_list)

elif mykey == "snakemake_rules":
    sample_sheet = sys.argv[3]
    sample_sheet_handle = open(sample_sheet)
    header = sample_sheet_handle.readline()
    pipeline_from_samplesheet = sample_sheet_handle.readline().split(',')[9]
    sample_sheet_handle.close()
    rules_list = snakemake_rules_dict[pipeline_from_samplesheet]
    print ' '.join(rules_list)
elif mykey == "organism":
    sample_sheet = sys.argv[3]
    sample_sheet_handle = open(sample_sheet)
    header = sample_sheet_handle.readline()
    organism_from_samplesheet = sample_sheet_handle.readline().split(',')[10]
    sample_sheet_handle.close()
    genome_length = organism_dict[organism_from_samplesheet]
    print genome_length
elif mykey == "genome_length_file":
    pass
    print genome_length_file


else:
    #print len(all_dict[mykey])
    print ' '.join(all_dict[mykey])


exit()


