pipeline {
    agent any
    stages {
        stage('build') {
            steps {
                sh 'packer build ami.json'
            }
        }
    }
}
