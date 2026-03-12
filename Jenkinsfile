pipeline {
    agent any

    environment {
        AWS_ACCESS_KEY_ID     = credentials('aws-access-key')
        AWS_SECRET_ACCESS_KEY = credentials('aws-secret-key')
        AWS_DEFAULT_REGION    = 'us-east-1'
    }

    stages {
        stage('Stage 1: Checkout') {
            steps {
                echo 'Pulling source code from GitHub...'
                checkout scm
            }
        }

        stage('Stage 2: Infrastructure Security Scan') {
            steps {
                echo 'Running Trivy to scan Terraform for misconfigurations...'
                sh 'trivy config ./terraform --severity HIGH,CRITICAL --exit-code 1'
            }
        }

        stage('Stage 3: Terraform Plan') {
            steps {
                echo 'Initializing and Planning AWS Infrastructure...'
                dir('terraform') {
                    sh 'terraform init'
                    sh 'terraform plan'
                }
            }
        }

        stage('Stage 4: Terraform Apply') {
            steps {
                echo 'Deploying Infrastructure to AWS...'
                dir('terraform') {
                    sh 'terraform apply -auto-approve'
                }
            }
        }
    }
    
    post {
        always {
            echo 'Pipeline execution complete. Check logs for Trivy vulnerability reports.'
        }
    }
}