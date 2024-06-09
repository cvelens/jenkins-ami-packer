pipeline {
    agent any

    environment {
        GITHUB_CREDENTIALS_ID = 'github'
        GITHUB_REPO_OWNER = 'cyse7125-su24-team15'
        GITHUB_REPO_NAME = 'ami-jenkins'
        GITHUB_API_URL = 'https://api.github.com/repos'
    }

    stages {
        stage('Checkout') {
            steps {
                script {
                    echo 'Checking out the repository...'
                    try {
                        git url: 'https://github.com/cyse7125-su24-team15/ami-jenkins.git', branch: 'main', credentialsId: 'github'
                    } catch (Exception e) {
                        echo "Checkout failed: ${e.message}"
                        currentBuild.result = 'FAILURE'
                        throw e
                    }
                }
            }
        }

        stage('Packer Validate') {
            steps {
                script {
                    echo 'Running Packer validate...'
                    def packerStatus = 'success'
                    try {
                        def result = sh(
                            script: 'packer validate ami.pkr.hcl',
                            returnStatus: true
                        )
                        if (result != 0) {
                            packerStatus = 'failure'
                            error('Packer validate check failed!')
                        }
                    } catch (Exception e) {
                        echo "Packer validate failed: ${e.message}"
                        packerStatus = 'failure'
                    } finally {
                        updateGitHubStatus('packer-validate', packerStatus, 'Packer Validate check')
                    }
                }
            }
        }

        stage('Create Commitlint Config') {
            steps {
                script {
                    echo 'Creating commitlint config...'
                    try {
                        sh '''
                            mkdir -p /tmp/commitlint-config
                            echo "module.exports = { extends: ['$(npm root -g)/@commitlint/config-conventional/lib/index.js'] };" > /tmp/commitlint-config/commitlint.config.js
                        '''
                    } catch (Exception e) {
                        echo "Creating commitlint config failed: ${e.message}"
                        currentBuild.result = 'FAILURE'
                        throw e
                    }
                }
            }
        }

        stage('Check Conventional Commits') {
            steps {
                script {
                    echo 'Checking Conventional Commits...'
                    def commitsStatus = 'success'
                    try {
                        def commits = sh(script: 'git log --pretty=format:"%s" upstream/main..HEAD', returnStdout: true).trim().split('\n')
                        echo "Commits to be checked: ${commits}"
                        def hasErrors = false
                        commits.each { commit ->
                            def result = sh(
                                script: """
                                    echo "${commit}" | commitlint --config /tmp/commitlint-config/commitlint.config.js
                                """,
                                returnStatus: true
                            )
                            if (result != 0) {
                                echo "Commit message failed: ${commit}"
                                hasErrors = true
                            }
                        }
                        if (hasErrors) {
                            commitsStatus = 'failure'
                            error('Conventional Commits check failed!')
                        }
                    } catch (Exception e) {
                        echo "Conventional Commits check failed: ${e.message}"
                        commitsStatus = 'failure'
                    } finally {
                        updateGitHubStatus('conventional-commits', commitsStatus, 'Conventional Commits check')
                    }
                }
            }
        }
    }

    post {
        always {
            script {
                echo 'Cleaning up...'
                deleteDir()
            }
        }
    }
}

void updateGitHubStatus(String context, String state, String description) {
    withCredentials([usernamePassword(credentialsId: env.GITHUB_CREDENTIALS_ID, usernameVariable: 'GITHUB_USERNAME', passwordVariable: 'GITHUB_TOKEN')]) {
        def GIT_COMMIT = sh(script: "git rev-parse HEAD", returnStdout: true).trim()
        sh """
            curl -H "Authorization: token ${GITHUB_TOKEN}" \
                 -H "Content-Type: application/json" \
                 -X POST \
                 -d '{
                     "state": "${state}",
                     "target_url": "${env.BUILD_URL}",
                     "description": "${description}",
                     "context": "${context}"
                 }' \
                 ${env.GITHUB_API_URL}/${env.GITHUB_REPO_OWNER}/${env.GITHUB_REPO_NAME}/statuses/${GIT_COMMIT}
        """
    }
}
