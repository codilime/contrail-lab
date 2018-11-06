#!groovy
library "atomSharedLibraries@${env.BRANCH_NAME}"

@Library("atomSharedLibraries@${env.BRANCH_NAME}")
import org.FileManager
import org.DirKeeper
import org.FileNameKeeper
import org.Constants

def warningEcho(message) {
    echo "\033[1;33m${message}\033[0m"
}

def copyTerraformFiles(FileManager fm, DirKeeper dk, FileNameKeeper fnk) {
    fm.copy(fnk.tfMainName(), dk.tfFilesDir(), dk.machineDir())
    fm.copy(fnk.tfVarsName(), dk.tfFilesDir(), dk.machineDir())
}

def copyDaemonFile(FileManager fm, DirKeeper dk, FileNameKeeper fnk) {
    fm.copy(fnk.daemonName(), dk.provisionDir(), dk.machineDir())
}

def resolveInstancesYamlFile(FileManager fm, DirKeeper dk, FileNameKeeper fnk) {
    if (fnk.userInstanceName() != "") {
        fm.move(fnk.userInstanceName(), "${dk.machineDir()}/${fnk.mainInstanceName()}")
    } else {
        warningEcho("Didn't get instances yaml file. Using default file.")
        fm.copy("${dk.provisionDir()}/${fnk.defaultInstanceName()}", "${dk.machineDir()}/${fnk.mainInstanceName()}")
    }
}

def prepareMachineDirectory(FileManager fm, DirKeeper dk, FileNameKeeper fnk) {
    fm.newDir(dk.machineDir())
    sh "chmod 500 ${dk.provisionDir()}/${fnk.prepareTemplateName()}"
    fm.copy(fnk.prepareTemplateName(), dk.provisionDir(), dk.machineDir())
    copyTerraformFiles(fm, dk, fnk)
    copyDaemonFile(fm, dk, fnk)
    resolveInstancesYamlFile(fm, dk, fnk)
    prepareKeyFiles(fm, dk, fnk)
}

def prepareKeyFiles(FileManager fm, DirKeeper dk, FileNameKeeper fnk) {
    if (fnk.userPubKeyName() != "" && fnk.userPrivKeyName() != "") {
        fm.move(fnk.userPubKeyName(), "${dk.machineDir()}/${fnk.mainPubKeyName()}")
        fm.move(fnk.userPrivKeyName(), "${dk.machineDir()}/${fnk.mainPrivKeyName()}")
    } else {
        warningEcho("Didn't get Public and Private SSH key. Using default keys.")
        fm.copy("${dk.provisionDir()}/${fnk.defaultPubKeyName()}", "${dk.machineDir()}/${fnk.mainPubKeyName()}")
        fm.copy("${dk.provisionDir()}/${fnk.defaultPrivKeyName()}", "${dk.machineDir()}/${fnk.mainPrivKeyName()}")
    }
    sh "chmod 600 ${dk.machineDir()}/${fnk.mainPubKeyName()}"
    sh "chmod 600 ${dk.machineDir()}/${fnk.mainPrivKeyName()}"
}

def setDirKeeper(DirKeeper dk) {
    dk.setMainDir("../${Constants.mainDirectoryName}")
    dk.setUserDir("../${Constants.mainDirectoryName}/${params.Login}")
    dk.setMachineDir("../${Constants.mainDirectoryName}/${params.Login}/${params.MachineName}")
    dk.setProvisionDir("provision")
    dk.setTfFilesDir("provision/${params.orchestrator}")
}

def setFileNameKeeper(FileNameKeeper fnk, String operation) {
    fnk.setDaemonName("daemon.json")
    fnk.setPrepareTemplateName("prepare_template")
    fnk.setTfVarsName("variables.tf")
    fnk.setTfMainName("${params.orchestrator}.tf")

    fnk.setDefaultPubKeyName("id_rsa.pub")
    fnk.setDefaultPrivKeyName("id_rsa")
    fnk.setDefaultInstanceName("template.yaml")

    fnk.setMainPubKeyName("${params.Login}-key.pub")
    fnk.setMainPrivKeyName("${params.Login}-key.priv")
    fnk.setMainInstanceName("instances.yaml")

    // Those files are needed only during creating new machine.
    if(operation == "--create") {
        // This is a workaround!
        // https://bitbucket.org/janvrany/jenkins-27413-workaround-library
        if ("${sshpubkey}" != "") {
            def sshPubKeyFile = unstashParam "sshpubkey"
            fnk.setUserPubKeyName("${sshPubKeyFile}")
        } else {
            fnk.setUserPubKeyName("")
        }

        if ("${sshprivkey}" != "") {
            def sshPrivKeyFile = unstashParam "sshprivkey"
            fnk.setUserPrivKeyName("${sshPrivKeyFile}")
        } else {
            fnk.setUserPrivKeyName("")
        }

        if ("${instances_yaml}" != "") {
            def instancesYaml = unstashParam "instances_yaml"
            fnk.setUserInstanceName("${instancesYaml}")
        } else {
            fnk.setUserInstanceName("")
        }
    }
}

def createContrail(FileManager fm, DirKeeper dk, FileNameKeeper fnk) {
    // set default value "master" for branch if not set
    String branch = params.branch
    if(params.branch == "") {
        branch = "master"
    }
    sh " \
        set +x && \
        terraform init ${dk.machineDir()} && \
        terraform apply -auto-approve  \
            -state-out=\"${dk.machineDir()}/${Constants.terraformStateFileName}\" \
            -var='user_name='\"${params.Login}\" \
            -var='password='\"${params.Password}\" \
            -var='project_id='\"${params.ProjectID}\" \
            -var='domain_name='\"${params.domainName}\" \
            -var='project_name='\"${params.projectName}\" \
            -var='network_name='\"${params.networkName}\" \
            -var='branch='\"${branch}\" \
            -var='ssh_key_file='\"${dk.machineDir()}/${fnk.mainPubKeyName()}\" \
            -var='ssh_private_key='\"${dk.machineDir()}/${fnk.mainPrivKeyName()}\" \
            -var='routerip='\"${params.routerIP}\" \
            -var='flavor='\"${params.flavor}\" \
            -var='machine_name='\"${params.MachineName}\" \
            -var='contrail_type='\"${params.contrail_type}\" \
            -var='patchset_ref='\"${params.patchset_ref}\" \
            -var='path='\"${dk.machineDir()}\" \
            \"${dk.machineDir()}\" && \
            set -x"
}

def destroyContrail(FileManager fm, DirKeeper dk, FileNameKeeper fnk) {
    sh " \
        set +x && \
        terraform init ${dk.machineDir()} && \
        terraform destroy -auto-approve \
            -state=\"${dk.machineDir()}/${Constants.terraformStateFileName}\" \
            -var \"user_name=${params.Login}\" \
            -var \"password=${params.Password}\" \
            -var \"project_id=${params.ProjectID}\" \
            -var \"domain_name=${params.domainName}\" \
            -var \"project_name=${params.projectName}\" \
            -var \"ssh_key_file=${dk.machineDir()}/${fnk.mainPubKeyName()}\" \
            -var \"ssh_private_key=${dk.machineDir()}/${fnk.mainPrivKeyName()}\" \
            -var \"machine_name=${params.MachineName}\" \
            -var \"path=${dk.machineDir()}\" \
        \"${dk.machineDir()}\" && \
        set -x"
}

pipeline {
    agent any

    options {
        ansiColor('xterm')
    }

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
                    deleteDir()
                    // Use the same repo and branch as was used to checkout Jenkinsfile:
                    retry(3) {
                        checkout scm
                    }
                    stash name: "Provision", includes: "provision/**"
                    unstash "Provision"

                    FileManager fm = ["${WORKSPACE}"]
                    DirKeeper dk = []
                    FileNameKeeper fnk = []

                    setDirKeeper(dk)
                    setFileNameKeeper(fnk, params.CreateDestroy)

                    // It's a workaround to pass those variables to post script
                    fm_post = fm
                    dk_post = dk
                    fnk_post = fnk

                    if ("${params.CreateDestroy}" == "--create") {
                        fm.newDir(dk.mainDir())
                        fm.newDir(dk.userDir())

                        if(fm.exists(dk.machineDir())){
                            error("It seems that there are actually resources with that name.\nPlease destroy them first or use if you just forgot about them. :)")
                        } else {
                            prepareMachineDirectory(fm, dk, fnk)
                            createContrail(fm, dk, fnk)
                        }
                    } else {
                        destroyContrail(fm, dk, fnk)
                        fm.del(dk.machineDir())
                    }
                }
            }
            post {
                always {
                    script {
                        FileManager fm = fm_post
                        DirKeeper dk = dk_post
                        FileNameKeeper fnk = fnk_post

                        if ("${params.CreateDestroy}" == "--create") {
                            fm.del("${dk.machineDir()}/${fnk.mainPrivKeyName()}")
                        }
                    }
                }
            }
        }
    }
}
