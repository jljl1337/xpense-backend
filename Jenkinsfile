pipeline {
    agent any

    environment {
        TEST_SECRET = credentials('test-secret')
    }

    stages {

        stage('Build') {
            steps {
                sh('docker build --load -t xpense-deploy .')
            }
        }

        // stage('Run') {
        //     steps {
        //         sh('docker run --rm xpense-deploy --dry-run')
        //     }
        // }

        stage('Cleanup') {
            steps {
                sh('docker rmi xpense-deploy')
            }
        }
    }
}