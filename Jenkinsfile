pipeline {
    agent any

    parameters{
                string(name: 'runName', defaultValue: 'TestRun', description: 'nom de la run MiSeq')
    }


    stages   {
        stage('InputRunName') {

                            steps {

                                echo "Stage InputRunName"
                                sh "/home/foueri01@inspq.qc.ca/GitScript/Jenkins/CheckRunName.sh ${params.runName}"
                            }
        }
        stage('Init'){
            environment{
                RUN_NAME = "${params.runName}"
            }
            steps{
                echo "Stage Init"
                    sh 'echo "In Jenkins file $RUN_NAME"'
              //      sh "/home/foueri01@inspq.qc.ca/GitScript/Jenkins/InitGenomicPipeline.sh"
              //      sh '/home/foueri01@inspq.qc.ca/GitScript/Jenkins/Tools.sh CoreSnvReference'
            }
        }
        stage('Trimmomatic'){
            environment{
                RUN_NAME = "${params.runName}"
            }
            steps{
                echo "Stage Trimmomatic"
                //sh "/home/foueri01@inspq.qc.ca/GitScript/Jenkins/DoTrimmomatic.sh"
            }
        }
        stage('Fastqc'){
            environment{
                RUN_NAME = "${params.runName}"
            }
            steps{
                echo "Stage Fastqc"
                //sh "/home/foueri01@inspq.qc.ca/GitScript/Jenkins/DoFastqc.sh"
            }
        }
        stage('Spades'){
            environment{
                RUN_NAME = "${params.runName}"
            }
            steps{
                echo "Stage Spades"
                //sh "/home/foueri01@inspq.qc.ca/GitScript/Jenkins/DoSpades.sh"
            }
        }
        stage('Qualimap'){
            environment{
                RUN_NAME = "${params.runName}"
            }
            steps{
                echo "Stage Qualimap"
                //sh "/home/foueri01@inspq.qc.ca/GitScript/Jenkins/DoQualimap.sh"
            }
        }
        stage('Quast'){
            environment{
                RUN_NAME = "${params.runName}"
            }
            steps{
                echo "Stage Quast"
                //sh "/home/foueri01@inspq.qc.ca/GitScript/Jenkins/DoQuast.sh"
            }
        }
        stage('Prokka'){
            environment{
                RUN_NAME = "${params.runName}"
            }
            steps{
                echo "Stage Prokka"
                //sh "/home/foueri01@inspq.qc.ca/GitScript/Jenkins/DoProkka.sh"
            }
        }
        stage('CoreSNV'){
            environment{
                RUN_NAME = "${params.runName}"
            }
            steps{
                echo "Stage CoreSNV"
                sh "/home/foueri01@inspq.qc.ca/GitScript/Jenkins/DoCoreSNV.sh"
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
                    . /home/foueri01@inspq.qc.ca/miniconda3/bin/activate funannotate
                    /home/foueri01@inspq.qc.ca/GitScript/Jenkins/DoFunannotate.sh
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
                    . /home/foueri01@inspq.qc.ca/miniconda3/bin/activate /data/Applications/Miniconda/miniconda3/envs/qiime2-2019.10
                    /home/foueri01@inspq.qc.ca/GitScript/Jenkins/DoQiime2.sh
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
                      /home/foueri01@inspq.qc.ca/GitScript/Jenkins/Tools.sh ComputeMiSeqStat
                      /home/foueri01@inspq.qc.ca/GitScript/Jenkins/Tools.sh CountReads
                      /home/foueri01@inspq.qc.ca/GitScript/Jenkins/Tools.sh ComputeExpectedGenomesCoverage
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
                /home/foueri01@inspq.qc.ca/GitScript/Jenkins/BuildWebReportV2.sh
                /home/foueri01@inspq.qc.ca/GitScript/Jenkins/Tools.sh AddNumericPrefixToSubdir
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
                      /home/foueri01@inspq.qc.ca/GitScript/Jenkins/Tools.sh Clean
                      /home/foueri01@inspq.qc.ca/GitScript/Jenkins/Tools.sh AddNumericPrefixToSubdir
                    '''
                */    
            }
        }
    }
}
