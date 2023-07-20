pipeline {
  agent {
    kubernetes {
      yaml '''
        apiVersion: v1
        kind: Pod
        spec:
          containers:
          - name: maven
            image: maven:alpine
            command:
            - cat
            tty: true
          - name: docker
            image: docker:latest
            command:
            - cat
            tty: true
            volumeMounts:
             - mountPath: /var/run/docker.sock
               name: docker-sock
          volumes:
          - name: docker-sock
            hostPath:
              path: /var/run/docker.sock    
        '''
    }
  }



  stages {

    stage('Config') {
      steps {
        script {

          //public variable definition
          stageList = ["Initialize", "Validation", "Code Checkout","Compilation","Deployment"]
          stageListSize = stageList.size()
          Random rnd = new Random()
          failedStage = rnd.nextInt(stageListSize)  //generate a random number which is the index of the stage that will fail


          println(rnd.nextInt(stageListSize)) // random integer in the range of 0, 3  (so one of 0,1, 2)
        }
      }
    } 


    stage('Compilation') {
      steps {
        container('maven') {
          sh ("mvn --version")

        }
        
        container('docker') {

          sh ("docker version")
        }        
        
      }
    }  


  }
}

def initialize() {
  def stage_list = ["Initialize", "Validation", "Code Checkout","Compilation","Deployment"]
  Random rnd = new Random()
  println(rnd.next(2)) // 2 bits of random number that is, one of the following: 0,1,2,3
  println(rnd.nextInt(3)) // random integer in the range of 0, 3  (so one of 0,1, 2)
}

