pipeline {
    agent any

    environment {
        DEPLOY_SERVER_1 = 'ec2-user@10.0.x.xxx'   // Primary EC2 instance's user and IP
        DEPLOY_SERVER_2 = 'ec2-user@10.0.x.xxx'   // Secondary EC2 instance's user and IP
        DEPLOY_PATH = '/var/www/html'             // Web server's deployment directory
        SSH_KEY_CREDENTIALS = 'yourkey'         // Jenkins credentials ID for SSH key
    }

    stages {
        stage('Download Web Application') {
            steps {
                sh 'wget https://github.com/azeezsalu/techmax/archive/refs/heads/main.zip -O techmax.zip'
            }
        }

        stage('Unzip Application') {
            steps {
                sh 'unzip techmax.zip -d techmax'
            }
        }

        stage('Deploy to EC2 Servers') {
            steps {
                sshagent(credentials: [SSH_KEY_CREDENTIALS]) {
                    // Deploy to first server
                    sh """
                    scp -o StrictHostKeyChecking=no -r techmax/techmax-main/* ${DEPLOY_SERVER_1}:${DEPLOY_PATH}
                    ssh ${DEPLOY_SERVER_1} 'sudo systemctl restart httpd'
                    """

                    // Deploy to second server
                    sh """
                    scp -o StrictHostKeyChecking=no -r techmax/techmax-main/* ${DEPLOY_SERVER_2}:${DEPLOY_PATH}
                    ssh ${DEPLOY_SERVER_2} 'sudo systemctl restart httpd'
                    """
                }
            }
        }
    }

    post {
        success {
            echo 'Deployment successful on both servers!'
        }
        failure {
            echo 'Deployment failed. Please check the logs.'
        }
    }
}
