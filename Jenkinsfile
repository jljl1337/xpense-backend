pipeline {
    agent any

    environment {
        DB_URL = credentials('supabase-db-url')
    }

    stages {
        stage('Build') {
            steps {
                sh('docker build --load -t xpense-deploy .')
            }
        }

        stage('Run') {
            steps {
                sh('docker run --rm -e DB_URL="$DB_URL" xpense-deploy')
            }
        }

        stage('Cleanup') {
            steps {
                sh('docker rmi xpense-deploy')
            }
        }
    }
}