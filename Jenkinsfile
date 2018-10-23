#!groovy
library "atomSharedLibraries@master"

import static Constants.*

class Constants {
    static final mainDirectoryName = "contrail_state_files"
    static final terraformStateFileName = "state"
}

def warningEcho(message) {
    echo "\033[1;33m${message}\033[0m"
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

def checkIfDirectoryExists(name) {
    return sh(script: "test -d \"${name}\" && echo '1' || echo '0' ", returnStdout: true).trim()
}

def checkIfFileExists(name) {
    return sh(script: "test -f \"${name}\" && echo '1' || echo '0' ", returnStdout: true).trim()
}

def copyTerraformFiles() {
    sh "cp provision/${params.orchestrator}/${params.orchestrator}.tf ../${mainDirectoryName}/${params.Login}/${params.MachineName}/${params.orchestrator}.tf"
    sh "cp provision/${params.orchestrator}/variables.tf ../${mainDirectoryName}/${params.Login}/${params.MachineName}/variables.tf"
}

def copyDaemonFile() {
    sh "cp provision/daemon.json ../${mainDirectoryName}/${params.Login}/${params.MachineName}/daemon.json"
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

def prepareMachineDirectory() {
    sh "mkdir ../${mainDirectoryName}/${params.Login}/${params.MachineName}"
    sh "chmod 777 provision/prepare_template"
    sh "cp provision/prepare_template ../${mainDirectoryName}/${params.Login}/${params.MachineName}/prepare_template"
    copyTerraformFiles()
    copyDaemonFile()
    resolveInstancesYamlFile()
    prepareKeyFiles()
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

pipeline {
    agent any
    parameters {
        string(defaultValue: "", description: "", name: "Login")
        password(defaultValue: "", description: "", name: "Password")
        string(defaultValue: "default", description: "", name: "MachineName")
        choice(choices: ["--create", "--destroy"], description: "", name: "CreateDestroy")
        string(description: "", name: "branch", defaultValue: "${branch}")
        string(description: "", name: "routerID", defaultValue: "${routerID}")
        string(description: "", name: "routerName", defaultValue: "${routerName}")
        string(description: "", name: "routerIP", defaultValue: "${routerIP}")
        string(description: "", name: "networkID", defaultValue: "${networkID}")
        string(description: "", name: "networkName", defaultValue: "${networkName}")
        string(description: "", name: "projectName", defaultValue: "${projectName}")
        string(description: "", name: "ProjectID", defaultValue: "${ProjectID}")
        string(description: "", name: "domainName", defaultValue: "${domainName}")
        file(description: "sshpubkey", name: "sshpubkey")
        file(description: "sshprivkey", name: "sshprivkey")
        file(description: "instances_yaml", name: "instances_yaml")
        choice(choices: ["kubernetes", "openstack"], description: "", name: "orchestrator")
        choice(choices: ["vnc_api", "contrail-go"], description: "", name: "contrail_type")
        string(description: "", name: "flavor", defaultValue: "${flavor}")
        string(defaultValue: "master", description: "", name: "patchset_ref")
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

                        ensureMainDirectoryExists()
                        ensureUserDirectoryExists()

                        dirExistingResult = checkIfDirectoryExists("../${mainDirectoryName}/${params.Login}/${params.MachineName}")
                        if(dirExistingResult == '1'){
                            error("It seems that there are actually resources with that name.\nPlease destroy them first or use if you just forgot about them. :)")
                        } else {
                            prepareMachineDirectory()
                            ansiColor('xterm') {
                                sh "set +x && cd provision && terraform init ../../${mainDirectoryName}/${params.Login}/${params.MachineName} && ./createcontrail \"--create\" \"${params.Login}\" \"${params.Password}\" \"${params.MachineName}\" \"${params.ProjectID}\" \"${params.domainName}\" \"${params.projectName}\" \"${params.networkName}\" \"../../${mainDirectoryName}/${params.Login}/${params.MachineName}/${params.Login}-key.pub\" \"../../${mainDirectoryName}/${params.Login}/${params.MachineName}/${params.Login}-key.priv\" \"${params.routerIP}\" \"${params.orchestrator}\" \"${params.branch}\" \"${params.flavor}\" \"${terraformStateFileName}\" \"${mainDirectoryName}\" \"${params.contrail_type}\" \"${params.patchset_ref}\" && set -x"
                            }
                        }
                    } else {
                        // set +x and set -x are workaround to not print user password in jenkins output log
                        ansiColor('xterm') {
                            sh "set +x && cd provision && terraform init ../../${mainDirectoryName}/${params.Login}/${params.MachineName} && ./createcontrail \"--destroy\" \"${params.Login}\" \"${params.Password}\" \"${params.MachineName}\" \"${params.ProjectID}\" \"${params.domainName}\" \"${params.projectName}\" \"${params.orchestrator}\" \"${terraformStateFileName}\" \"${mainDirectoryName}\" && set -x"
                        }
                        sh "rm -rf ../${mainDirectoryName}/${params.Login}/${params.MachineName}"
                    }
                }
            }
        }
    }
    post {
        always {
            script {
                if ("${sshpubkey}" != "" && "${sshprivkey}" != "" && "${params.CreateDestroy}" == "--create") {
                    sh "rm -rf ../${mainDirectoryName}/${params.Login}/${params.MachineName}/${params.Login}-key.pub"
                    sh "rm -rf ../${mainDirectoryName}/${params.Login}/${params.MachineName}/${params.Login}-key.priv"
                }
            }
        }
    }
}
