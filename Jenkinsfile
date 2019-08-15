
pipeline {
    agent any

    stages   {
        stage('InputRunName') {

			    steps {
                  	        //voir https://stackoverflow.com/questions/46276140/jenkins-declarative-pipeline-user-input-parameters
	     			timeout(60){
			    		script{
						echo "temp"
						pathMap = input id: 'pathInput', message: "Chemin vers les données", ok: 'Continuer', parameters: [string(name: 'RunName', defaultValue: '', description: 'Nom de la run'),string(name: 'temp', defaultValue: 'temp', description: 'pour empecher bug')]
			
				              }			    
                                            }
				echo "Stage InputRunName"
				sh "/home/foueri01@inspq.qc.ca/GitScript/Jenkins/CheckRunName.sh ${pathMap['RunName']}"
				  }
                       }
	stage('Init'){
			    
                             environment{

						RUN_NAME = "${pathMap['RunName']}"
			                }
			    steps{
				echo "Stage Init"
				//sh 'echo "In Jenkins file $RUN_NAME"'
				sh "/home/foueri01@inspq.qc.ca/GitScript/Jenkins/InitGenomicPipeline.sh"
				sh '/home/foueri01@inspq.qc.ca/GitScript/Jenkins/Tools.sh CoreSnvReference'
                                 }
		     }
	stage('Trimmomatic'){
                             environment{

						RUN_NAME = "${pathMap['RunName']}"
			                }
			        steps{	
					echo "Stage Trimmomatic"
					sh "/home/foueri01@inspq.qc.ca/GitScript/Jenkins/DoTrimmomatic.sh"
				     }	
			    }		
	stage('Fastqc'){
                             environment{

						RUN_NAME = "${pathMap['RunName']}"
			                }

				steps{
					echo "Stage Fastqc"
					sh "/home/foueri01@inspq.qc.ca/GitScript/Jenkins/DoFastqc.sh"
					
				     }
		       }
	stage('Spades'){
                             environment{

						RUN_NAME = "${pathMap['RunName']}"
			                }

			       steps{
					echo "Stage Spades"
					sh "/home/foueri01@inspq.qc.ca/GitScript/Jenkins/DoSpades.sh"
				    }
		       }
	stage('Qualimap'){
                             environment{

						RUN_NAME = "${pathMap['RunName']}"
			                }

			       steps{
					echo "Stage Qualimap"
					sh "/home/foueri01@inspq.qc.ca/GitScript/Jenkins/DoQualimap.sh"
				    }
		       }
	stage('Prokka'){
                             environment{

						RUN_NAME = "${pathMap['RunName']}"
			                }

			       steps{
					echo "Stage Prokka"
					sh "/home/foueri01@inspq.qc.ca/GitScript/Jenkins/DoProkka.sh"
				    }
		       }
	stage('CoreSNV'){
                             environment{

						RUN_NAME = "${pathMap['RunName']}"
			                }
			     steps{
					echo "Stage CoreSNV"
					sh "/home/foueri01@inspq.qc.ca/GitScript/Jenkins/DoCoreSNV.sh"
				  }

			}
	stage('Funannotate'){
                             environment{

						RUN_NAME = "${pathMap['RunName']}"
			                }
			     steps{
					echo "Stage Funannotate"
				              	
                                        sh '''#!/bin/bash
				           . /home/foueri01@inspq.qc.ca/miniconda3/bin/activate funannotate
					   /home/foueri01@inspq.qc.ca/GitScript/Jenkins/DoFunannotate.sh
				           conda deactivate
					   
					'''
					
				  }

			}
	stage('RunStat'){
                             environment{

						RUN_NAME = "${pathMap['RunName']}"
			                }

			     steps{

					echo "In Stage RunStat"
					//voir https://stackoverflow.com/questions/40213654/how-to-invoke-bash-functions-defined-in-a-resource-file-from-a-jenkins-pipeline?rq=1
                                                                             
					sh '''#!/bin/bash
				      		/home/foueri01@inspq.qc.ca/GitScript/Jenkins/Tools.sh ComputeMiSeqStat
				      		/home/foueri01@inspq.qc.ca/GitScript/Jenkins/Tools.sh CountReads
				      		/home/foueri01@inspq.qc.ca/GitScript/Jenkins/Tools.sh ComputeExpectedGenomesCoverage
				      
				   	   '''
					  
       					                                  
			        }
			}
	stage('Clean'){
                             environment{

						RUN_NAME = "${pathMap['RunName']}"
			                }

			     steps{

					echo "In Stage Clean"
					
					sh '''#!/bin/bash
				      		/home/foueri01@inspq.qc.ca/GitScript/Jenkins/Tools.sh Clean
				      		/home/foueri01@inspq.qc.ca/GitScript/Jenkins/Tools.sh AddNumericPrefixToSubdir
				      
				   	   '''	
			        }
			}
	
   }
}


