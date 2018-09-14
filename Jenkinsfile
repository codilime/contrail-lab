#!groovy
library "atomSharedLibraries@master"

pipeline {
    agent any
    stages {
        stage('Main') {
            steps {
                script {
                    if ("${CreateDestroy}" == "--create") {
                        deleteDir()
                        // Use the same repo and branch as was used to checkout Jenkinsfile:
                        retry(3) {
                            checkout scm
                        }
                        stash name: "Provision", includes: "provision/**"
                        unstash "Provision"

                        if ("${sshpubkey}" != "" && "${sshprivkey}" != "") {
                            // This is a workaround!
                            // https://bitbucket.org/janvrany/jenkins-27413-workaround-library
                            def sshPubKeyFile = unstashParam "sshpubkey"
                            def sshPrivKeyFile = unstashParam "sshprivkey"
                            def instancesYaml = unstashParam "instances_yaml"
                            sh "mv ${sshPubKeyFile} ${Login}-key.pub"
                            sh "mv ${sshPrivKeyFile} ${Login}-key.priv"
                            sh "rm -rf ${sshPubKeyFile}"
                            sh "rm -rf ${sshPrivKeyFile}"
                            sh "mv ${instancesYaml} provision/template.yaml"
                            sh "chmod 600 ${Login}-key.pub"
                            sh "chmod 600 ${Login}-key.priv"
                            sh "chmod 777 provision/prepare_template"
                            // set +x and set -x are workaround to not print user password in jenkins output log
                            ansiColor('xterm') {
                                sh "set +x && cd provision && terraform init -from-module ${orchestrator} && ./createcontrail \"--create\" \"${Login}\" \"${Password}\" \"${ProjectID}\" \"${domainName}\" \"${projectName}\" \"${networkName}\" \"../${Login}-key.pub\" \"../${Login}-key.priv\" \"${routerIP}\" \"${orchestrator}\" \"${branch}\" \"${flavor}\" && set -x"
                            }
                        } else {
                            ansiColor('xterm') {
                                sh "set +x && cd provision && terraform init -from-module ${orchestrator} && ./createcontrail \"--create\" \"${Login}\" \"${Password}\" \"${ProjectID}\" \"${domainName}\" \"${projectName}\" \"${networkName}\" \"./id_rsa.pub\" \"./id_rsa\" \"${routerIP}\" \"${orchestrator}\" \"${branch}\" \"${flavor}\" && set -x"
                            }
                        }
                    } else {
                        // set +x and set -x are workaround to not print user password in jenkins output log
                        ansiColor('xterm') {
                            sh "set +x && cd provision && ./createcontrail \"--destroy\" \"${Login}\" \"${Password}\" \"${ProjectID}\" \"${domainName}\" \"${projectName}\" \"${orchestrator}\" && set -x"
                        }
                    }
                }
            }
        }
    }
    post {
        always {
            script {
                if ("${sshpubkey}" != "" && "${sshprivkey}" != "" && "${CreateDestroy}" == "--create") {
                    sh "rm -rf ${Login}-key.pub"
                    sh "rm -rf ${Login}-key.priv"
                }
            }
        }
        failure {
            script {
                if ("${CreateDestroy}" == "--create") {
                    ansiColor('xterm') {
                        sh "set +x && cd provision && ./createcontrail \"--destroy\" \"${Login}\" \"${Password}\" \"${ProjectID}\" \"${domainName}\" \"${projectName}\" \"${orchestrator}\" && set -x"
                    }
                }
            }
        }
    }
}
