
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
				echo "In Stage InputRunName"
				  }
                       }

	stage('Init'){
			    
                             environment{

						RUN_NAME = "${pathMap['RunName']}"
			                }
			    steps{
				echo "In Stage Init"
				//sh 'echo "In Jenkins file $RUN_NAME"'
				sh "/home/foueri01@inspq.qc.ca/GitScript/Jenkins/InitGenomicPipeline.sh"
			        }

                     }


	stage('Trimmomatic'){
                             environment{

						RUN_NAME = "${pathMap['RunName']}"
			                }
			        steps{	
					echo "In Stage Trimmomatic"
					//sh "/home/foueri01@inspq.qc.ca/GitScript/Jenkins/DoTrimmomatic.sh"
				     }	
			    }		

	stage('Fastqc'){
                             environment{

						RUN_NAME = "${pathMap['RunName']}"
			                }

				steps{
					echo "In Stage Fastqc"
					//sh "/home/foueri01@inspq.qc.ca/GitScript/Jenkins/DoFastqc.sh"
					
				     }
		       }


	stage('Spades'){
                             environment{

						RUN_NAME = "${pathMap['RunName']}"
			                }

			       steps{
					echo "In Stage Spades"
					//sh "/home/foueri01@inspq.qc.ca/GitScript/Jenkins/DoSpades.sh"
				    }
		       }

	stage('Prokka'){
                             environment{

						RUN_NAME = "${pathMap['RunName']}"
			                }

			       steps{
					echo "In Stage Prokka"
					//sh "/home/foueri01@inspq.qc.ca/GitScript/Jenkins/DoProkka.sh"
				    }
		       }

   }
}


