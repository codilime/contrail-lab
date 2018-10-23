#!groovy
library "atomSharedLibraries@master"

// This file uses lock(''){} function. In case if it's not working
// it means you need to install lockable plugin on jenkins.
// https://wiki.jenkins.io/display/JENKINS/Lockable+Resources+Plugin

import static Constants.*
import static ErrorCode.*

class Constants {
    static final mainDirectoryName = "contrail_state_files"
    static final terraformStateFileName = "state"
}

class ErrorCode {
    static final notCaughtError = 0
    static final machineExistsError = 1
    static final wrongParametersError = 2
    static final noMainDirectory = 3
}

def errorEcho(message, errorCode) {
    echo "\033[1;91m${message}\033[0m"
    globalError = errorCode
    error("${message}")
}

def greenEcho(message) {
    echo "\033[1;32m${message}\033[0m"
}

def warningEcho(message) {
    echo "\033[1;33m${message}\033[0m"
}

def prepareKeyFiles() {
    // This is a workaround!
    // https://bitbucket.org/janvrany/jenkins-27413-workaround-library
    if ("${sshpubkey}" != "" && "${sshprivkey}" != "") {
        def sshPubKeyFile = unstashParam "sshpubkey"
        def sshPrivKeyFile = unstashParam "sshprivkey"
        sh "mv ${sshPubKeyFile} ../${mainDirectoryName}/${params.Login}/${params.MachineName}/${params.Login}-key.pub"
        sh "mv ${sshPrivKeyFile} ../${mainDirectoryName}/${params.Login}/${params.MachineName}/${params.Login}-key.priv"
        sh "rm -rf ${sshPubKeyFile}"
        sh "rm -rf ${sshPrivKeyFile}"
    } else {
        warningEcho("Didn't get Public and Private SSH key. Using default keys.")
        sh "cp provision/id_rsa.pub ../${mainDirectoryName}/${params.Login}/${params.MachineName}/${params.Login}-key.pub"
        sh "cp provision/id_rsa ../${mainDirectoryName}/${params.Login}/${params.MachineName}/${params.Login}-key.priv"
    }
    sh "chmod 600 ../${mainDirectoryName}/${params.Login}/${params.MachineName}/${params.Login}-key.pub"
    sh "chmod 600 ../${mainDirectoryName}/${params.Login}/${params.MachineName}/${params.Login}-key.priv"
}

def copyTerraformFiles() {
    sh "cp provision/${params.orchestrator}/${params.orchestrator}.tf ../${mainDirectoryName}/${params.Login}/${params.MachineName}/${params.orchestrator}.tf"
    sh "cp provision/${params.orchestrator}/variables.tf ../${mainDirectoryName}/${params.Login}/${params.MachineName}/variables.tf"
}

def checkIfDirectoryExists(name) {
    return sh(script: "test -d \"${name}\" && echo '1' || echo '0' ", returnStdout: true).trim()
}

def checkIfFileExists(name) {
    return sh(script: "test -f \"${name}\" && echo '1' || echo '0' ", returnStdout: true).trim()
}

def refreshCheckoutDirectory() {
    lock('shared files area') {
        deleteDir()
        // Use the same repo and branch as was used to checkout Jenkinsfile:
        retry(3) {
            checkout scm
        }
        stash name: "Provision", includes: "provision/**"
        unstash "Provision"
    }
}

def ensureMainDirectoryExists() {
    dirExistingResult = checkIfDirectoryExists("../${mainDirectoryName}")
    if(dirExistingResult == '0') {
        sh "mkdir ../${mainDirectoryName}"
    }
}

def ensureUserDirectoryExists() {
    dirExistingResult = checkIfDirectoryExists("../${mainDirectoryName}/${params.Login}")
    if(dirExistingResult == '0') {
        sh "mkdir ../${mainDirectoryName}/${params.Login}"
    }
}

def resolveInstancesYamlFile() {
    if ("${instances_yaml}" != "") {
        def instancesYaml = unstashParam "instances_yaml"
        sh "mv ${instancesYaml} ../${mainDirectoryName}/${params.Login}/${params.MachineName}/template.yaml"
    } else {
        warningEcho("Didn't get instances yaml file. Using default file.")
        sh "cp provision/template.yaml ../${mainDirectoryName}/${params.Login}/${params.MachineName}/template.yaml"
    }
}

def copyDaemonFile() {
    sh "cp provision/daemon.json ../${mainDirectoryName}/${params.Login}/${params.MachineName}/daemon.json"
}

def prepareMachineDirectory() {
    sh "mkdir ../${mainDirectoryName}/${params.Login}/${params.MachineName}"
    sh "chmod 777 provision/prepare_template"
    sh "cp provision/prepare_template ../${mainDirectoryName}/${params.Login}/${params.MachineName}/prepare_template"
    copyTerraformFiles()
    copyDaemonFile()
    resolveInstancesYamlFile()
    prepareKeyFiles()
}

def operationCreate() {
    lock('shared files area') {
        ensureMainDirectoryExists()
        ensureUserDirectoryExists()
        dirExistingResult = checkIfDirectoryExists("../${mainDirectoryName}/${params.Login}/${params.MachineName}")
        if (dirExistingResult == '0') {
            prepareMachineDirectory()
        }
    }
    if(dirExistingResult == '1'){
        errorEcho("It seems that there are actually resources with that name.\nPlease destroy them first or use if you just forgot about them. :)", machineExistsError)
    } else {
        sh "set +x && cd provision && terraform init ../../${mainDirectoryName}/${params.Login}/${params.MachineName} && ./createcontrail \"--create\" \"${params.Login}\" \"${params.Password}\" \"${params.MachineName}\" \"${params.ProjectID}\" \"${params.domainName}\" \"${params.projectName}\" \"${params.networkName}\" \"../../${mainDirectoryName}/${params.Login}/${params.MachineName}/${params.Login}-key.pub\" \"../../${mainDirectoryName}/${params.Login}/${params.MachineName}/${params.Login}-key.priv\" \"${params.routerIP}\" \"${params.orchestrator}\" \"${params.branch}\" \"${params.flavor}\" \"${terraformStateFileName}\" \"${mainDirectoryName}\" \"${params.contrail_type}\" \"${params.patchset_ref}\" && set -x"
    }
}

def operationDestroy() {
    // set +x and set -x are workaround to not print user password in jenkins output log
    sh "set +x && cd provision && terraform init ../../${mainDirectoryName}/${params.Login}/${params.MachineName} && ./createcontrail \"--destroy\" \"${params.Login}\" \"${params.Password}\" \"${params.MachineName}\" \"${params.ProjectID}\" \"${params.domainName}\" \"${params.projectName}\" \"${params.orchestrator}\" \"${terraformStateFileName}\" \"${mainDirectoryName}\" && set -x"
    sh "rm -rf ../${mainDirectoryName}/${params.Login}/${params.MachineName}"
}

def operationListResources() {
    throwErrorIfMainDirectoryDoesntExist()
    throwErrorIfUserDirectoryDoesntExist()
    sh "set +x && terraform state list -state=\"../${mainDirectoryName}/${params.Login}/${params.MachineName}/${terraformStateFileName}\" && set -x"
}

def operationListUsers() {
    throwErrorIfMainDirectoryDoesntExist()
    greenEcho("Avaiable users:")
    sh "ls ../${mainDirectoryName}"
}

def deleteMachineDir() {
    throwErrorIfMainDirectoryDoesntExist()
    throwErrorIfUserDirectoryDoesntExist()
    throwErrorIfMachineDirectoryDoesntExist()
    sh "rm -rf ../${mainDirectoryName}/${params.Login}/${params.MachineName}"
}

def deleteUserDir() {
    throwErrorIfMainDirectoryDoesntExist()
    throwErrorIfUserDirectoryDoesntExist()
    sh "rm -rf ../${mainDirectoryName}/${params.Login}"
}

def throwErrorIfMainDirectoryDoesntExist() {
    dirExistingResult = checkIfDirectoryExists("../${mainDirectoryName}")
    if (dirExistingResult == '0') {
        errorEcho("Main directory doesn't exist. Please run --create first.", noMainDirectory)
    }
}

def throwErrorIfUserDirectoryDoesntExist() {
    dirExistingResult = checkIfDirectoryExists("../${mainDirectoryName}/${params.Login}")
    if (dirExistingResult == '0') {
        errorEcho("There is no user ${params.Login} specified.", wrongParametersError)
    }
}

def throwErrorIfMachineDirectoryDoesntExist() {
    dirExistingResult = checkIfDirectoryExists("../${mainDirectoryName}/${params.Login}/${params.MachineName}")
    if (dirExistingResult == '0') {
        errorEcho("There is no machine ${params.MachineName} created.", wrongParametersError)
    }
}

def operationListMachines() {
    throwErrorIfMainDirectoryDoesntExist()
    throwErrorIfUserDirectoryDoesntExist()
    greenEcho("Currently existing machines:")
    sh "ls ../${mainDirectoryName}/${params.Login}"
}

pipeline {
    agent any
    options {
        ansiColor('xterm')
    }
    parameters {
        string(defaultValue: '', description: '', name: 'Login')
        password(defaultValue: '', description: '', name: 'Password')
        string(defaultValue: "default", description: '', name: 'MachineName')
        choice(choices: [
            '--create',
            '--destroy',
            '--list-resources',
            '--list-machines',
            '--list-users',
            '--refresh-workspace',
            '--delete-user-dir',
            '--delete-machine-dir'
            ], description: '', name: 'Operation')
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
        choice(choices: ['vnc_api', 'contrail-go'], description: '', name: 'contrail_type')
        string(description: '', name: 'flavor', defaultValue: "${flavor}")
        string(defaultValue: 'master', description: '', name: 'patchset_ref')
    }
    stages {
        stage('Main') {
            steps {
                script {
                    globalError = 0
                    if ("${params.Operation}" == "--create") {
                        operationCreate()
                    } else if ("${params.Operation}" == "--destroy") {
                        operationDestroy()
                    } else if ("${params.Operation}" == "--list-resources") {
                        operationListResources()
                    } else if ("${params.Operation}" == "--list-users") {
                        operationListUsers()
                    } else if ("${params.Operation}" == "--list-machines") {
                        operationListMachines()
                    } else if ("${params.Operation}" == "--refresh-workspace") {
                        refreshCheckoutDirectory()
                    } else if ("${params.Operation}" == "--delete-machine-dir") {
                        deleteMachineDir()
                    } else if ("${params.Operation}" == "--delete-user-dir") {
                        deleteUserDir()
                    }
                }
            }
        }
    }
    post {
        always {
            script {
                if ("${sshpubkey}" != "" && "${sshprivkey}" != "" && "${params.Operation}" == "--create") {
                    sh "rm -rf ../${mainDirectoryName}/${params.Login}/${params.MachineName}/${params.Login}-key.pub"
                    sh "rm -rf ../${mainDirectoryName}/${params.Login}/${params.MachineName}/${params.Login}-key.priv"
                }
            }
        }
        failure {
            script {
                if ("${params.Operation}" == "--create") {
                    echo "${globalError}"
                    if (globalError == notCaughtError){
                        // If there is no error code it means there had to be an error during creating contrail.
                        operationDestroy()
                    }
                }
            }
        }
    }
}
