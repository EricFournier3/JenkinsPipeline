pipeline {
    agent any

    parameters{
                string(name: 'runName', defaultValue: 'TestRun', description: 'nom de la run MiSeq')
    }


    stages   {
        stage('InputRunName') {

                            steps {

                                echo "Stage InputRunName"
                                sh "/data/Applications/GitScript/Jenkins/CheckRunName.sh ${params.runName}"
                            }
        }
        stage('Init'){
            environment{
                RUN_NAME = "${params.runName}"
            }
            steps{
                echo "Stage Init"
                    sh 'echo "In Jenkins file $RUN_NAME"'
              //      sh "/data/Applications/GitScript/Jenkins/InitGenomicPipeline.sh"
              //      sh '/data/Applications/GitScript/Jenkins/Tools.sh CoreSnvReference'
            }
        }
        stage('Trimmomatic'){
            environment{
                RUN_NAME = "${params.runName}"
            }
            steps{
                echo "Stage Trimmomatic"
                //sh "/data/Applications/GitScript/Jenkins/DoTrimmomatic.sh"
            }
        }
        stage('Fastqc'){
            environment{
                RUN_NAME = "${params.runName}"
            }
            steps{
                echo "Stage Fastqc"
                //sh "/data/Applications/GitScript/Jenkins/DoFastqc.sh"
            }
        }
        stage('Spades'){
            environment{
                RUN_NAME = "${params.runName}"
            }
            steps{
                echo "Stage Spades"
                //sh "/data/Applications/GitScript/Jenkins/DoSpades.sh"
            }
        }
        stage('Qualimap'){
            environment{
                RUN_NAME = "${params.runName}"
            }
            steps{
                echo "Stage Qualimap"
                //sh "/data/Applications/GitScript/Jenkins/DoQualimap.sh"
            }
        }
        stage('Quast'){
            environment{
                RUN_NAME = "${params.runName}"
            }
            steps{
                echo "Stage Quast"
                //sh "/data/Applications/GitScript/Jenkins/DoQuast.sh"
            }
        }
        stage('Prokka'){
            environment{
                RUN_NAME = "${params.runName}"
            }
            steps{
                echo "Stage Prokka"
                //sh "/data/Applications/GitScript/Jenkins/DoProkka.sh"
            }
        }
        stage('CoreSNV'){
            environment{
                RUN_NAME = "${params.runName}"
            }
            steps{
                echo "Stage CoreSNV"
                sh "/data/Applications/GitScript/Jenkins/DoCoreSNV.sh"
            }
        }
        stage('Funannotate'){
            environment{
                RUN_NAME = "${params.runName}"
            }
            steps{
                echo "Stage Funannotate"
                /*
                sh '''#!/bin/bash
                    . /data/Applications/Miniconda/miniconda3/bin/activate /data/Applications/Miniconda/miniconda3/envs/funannotate_shared_v171
                    /data/Applications/GitScript/Jenkins/DoFunannotate.sh
                    conda deactivate
                '''
                */
            }
        }
	stage('Qiime'){
            environment{   
                RUN_NAME = "${params.runName}"
            }
            steps{
                echo "Stage Qiime"
                sh '''#!/bin/bash
                    . /data/Applications/Miniconda/miniconda3/bin/activate /data/Applications/Miniconda/miniconda3/envs/qiime2-2019.10
                    /data/Applications/GitScript/Jenkins/DoQiime2.sh
                    conda deactivate
                '''
            }
        }
        stage('RunStat'){
            environment{
                RUN_NAME = "${params.runName}"
            }
            steps{
                echo "In Stage RunStat"
                //voir https://stackoverflow.com/questions/40213654/how-to-invoke-bash-functions-defined-in-a-resource-file-from-a-jenkins-pipeline?rq=1
                /*
                sh '''#!/bin/bash
                      /data/Applications/GitScript/Jenkins/Tools.sh ComputeMiSeqStat
                      /data/Applications/GitScript/Jenkins/Tools.sh CountReads
                      /data/Applications/GitScript/Jenkins/Tools.sh ComputeExpectedGenomesCoverage
                '''
                */
            }
        }
        stage('WebReport'){
            environment{
                RUN_NAME = "${params.runName}"
                STAGE = "WEB_REPORT"
            }
            steps{
                echo "In Stage WebReport"
                /*
                sh '''#!/bin/bash
                /data/Applications/GitScript/Jenkins/BuildWebReportV2.sh
                /data/Applications/GitScript/Jenkins/Tools.sh AddNumericPrefixToSubdir
                '''
                */
            }
        }
         stage('Clean'){
            environment{
                RUN_NAME = "${params.runName}"
                STAGE = "CLEAN"
            }
            steps{
                echo "In Stage Clean"
                /*
                sh '''#!/bin/bash
                      /data/Applications/GitScript/Jenkins/Tools.sh Clean
                      /data/Applications/GitScript/Jenkins/Tools.sh AddNumericPrefixToSubdir
                    '''
                */    
            }
        }
    }
}
