#!groovy
library "atomSharedLibraries@master"

pipeline {
    agent any
    parameters {
        string(defaultValue: "", description: '', name: 'Login')
        password(defaultValue: "", description: '', name: 'Password')
        choice(choices: ['--create', '--destroy'], description: '', name: 'CreateDestroy')
        string(description: '', name: 'branch', defaultValue: "${branch}")
        string(description: '', name: 'routerID', defaultValue: "${routerID}")
        string(description: '', name: 'routerName', defaultValue: "${routerName}")
        string(description: '', name: 'routerIP', defaultValue: "${routerIP}")
        string(description: '', name: 'networkID', defaultValue: "${networkID}")
        string(description: '', name: 'networkName', defaultValue: "${networkName}")
        string(description: '', name: 'projectName', defaultValue: "${projectName}")
        string(description: '', name: 'ProjectID', defaultValue: "${ProjectID}")
        string(description: '', name: 'domainName', defaultValue: "${domainName}")
        file(description: 'sshpubkey', name: 'sshpubkey')
        file(description: 'sshprivkey', name: 'sshprivkey')
        file(description: 'instances_yaml', name: 'instances_yaml')
        choice(choices: ['kubernetes', 'openstack'], description: '', name: 'orchestrator')
        string(description: '', name: 'flavor', defaultValue: "${flavor}")
    }
    stages {
        stage('Main') {
            steps {
                script {
                    if ("${params.CreateDestroy}" == "--create") {
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
                            sh "mv ${sshPubKeyFile} ${params.Login}-key.pub"
                            sh "mv ${sshPrivKeyFile} ${params.Login}-key.priv"
                            sh "rm -rf ${sshPubKeyFile}"
                            sh "rm -rf ${sshPrivKeyFile}"
                            sh "mv ${instancesYaml} provision/template.yaml"
                            sh "chmod 600 ${params.Login}-key.pub"
                            sh "chmod 600 ${params.Login}-key.priv"
                            sh "chmod 777 provision/prepare_template"
                            // set +x and set -x are workaround to not print user password in jenkins output log
                            ansiColor('xterm') {
                                sh "set +x && cd provision && terraform init -from-module ${params.orchestrator} && ./createcontrail \"--create\" \"${params.Login}\" \"${params.Password}\" \"${params.ProjectID}\" \"${params.domainName}\" \"${params.projectName}\" \"${params.networkName}\" \"../${params.Login}-key.pub\" \"../${params.Login}-key.priv\" \"${params.routerIP}\" \"${params.orchestrator}\" \"${params.branch}\" \"${params.flavor}\" && set -x"
                            }
                        } else {
                            ansiColor('xterm') {
                                sh "set +x && cd provision && terraform init -from-module ${params.orchestrator} && ./createcontrail \"--create\" \"${params.Login}\" \"${params.Password}\" \"${params.ProjectID}\" \"${params.domainName}\" \"${params.projectName}\" \"${params.networkName}\" \"./id_rsa.pub\" \"./id_rsa\" \"${params.routerIP}\" \"${params.orchestrator}\" \"${params.branch}\" \"${params.flavor}\" && set -x"
                            }
                        }
                    } else {
                        // set +x and set -x are workaround to not print user password in jenkins output log
                        ansiColor('xterm') {
                            sh "set +x && cd provision && ./createcontrail \"--destroy\" \"${params.Login}\" \"${params.Password}\" \"${params.ProjectID}\" \"${params.domainName}\" \"${params.projectName}\" \"${params.orchestrator}\" && set -x"
                        }
                    }
                }
            }
        }
    }
    post {
        always {
            script {
                if ("${sshpubkey}" != "" && "${sshprivkey}" != "" && "${params.CreateDestroy}" == "--create") {
                    sh "rm -rf ${params.Login}-key.pub"
                    sh "rm -rf ${params.Login}-key.priv"
                }
            }
        }
        failure {
            script {
                if ("${params.CreateDestroy}" == "--create") {
                    ansiColor('xterm') {
                        sh "set +x && cd provision && ./createcontrail \"--destroy\" \"${params.Login}\" \"${params.Password}\" \"${params.ProjectID}\" \"${params.domainName}\" \"${params.projectName}\" \"${params.orchestrator}\" && set -x"
                    }
                }
            }
        }
    }
}