#!groovy
library "atomSharedLibraries@${env.BRANCH_NAME}"

// atomSharedLibraries is a shared library that must point to this repository.
// This is configured in shared libraries in global jenkins configuration.

@Library("atomSharedLibraries@master")
import org.FileManager
import org.KeyManager
import org.UserDirectory
import org.MachineConfiguration
import org.TerraformManager

def warningEcho(message) {
    echo "\033[1;33m${message}\033[0m"
}

def resolveInstancesYamlFile(String instanceParameter, String workspace) {
    if (instanceParameter != "")
        return "${workspace}/${instanceParameter}"
    warningEcho("Didn't get instances yaml file. Using default file.")
    return "provision/template.yaml"
}

def resolveKeyFile(String keyParameter, String workspace) {
    if (keyParameter != "")
        return "${workspace}/${keyParameter}"
    return ""
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
        choice(choices: ["--create", "--destroy", "--delete-machine-dir"], description: "", name: "Operation")
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
        choice(choices: ["yes", "no"], description: "Auto-destroy machine if building failed.", name: "destroy_if_failed")
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

                    String privKey = resolveKeyFile(unstashParam("sshprivkey"), fm.GetWorkspace())
                    String pubKey = resolveKeyFile(unstashParam("sshpubkey"), fm.GetWorkspace())
                    KeyManager km = [privKey, pubKey, fm]

                    UserDirectory userDir = ["../contrail_state_files", params.Login, params.MachineName, fm, fm.GetWorkspace()]
                    userDir.CreateUserDirectory()

                    String instancesFile = resolveInstancesYamlFile(unstashParam("instances_yaml"), fm.GetWorkspace())
                    TerraformManager tf = ["provision/${params.orchestrator}/variables.tf", "provision/${params.orchestrator}/${params.orchestrator}.tf", "provision/daemon.json", instancesFile, "provision/prepare_template", "provision/run-cad-k8s", fm]

                    MachineConfiguration conf = []
                    conf.UserName = params.Login
                    conf.Password = params.Password
                    conf.ProjectID = params.ProjectID
                    conf.DomainName = params.domainName
                    conf.ProjectName = params.projectName
                    conf.NetworkName = params.networkName
                    conf.Branch = params.branch
                    conf.RouterIP = params.routerIP
                    conf.Flavor = params.flavor
                    conf.MachineName = params.MachineName
                    conf.ContrailType = params.contrail_type
                    conf.PatchsetRef = params.patchset_ref

                    // It's a workaround to pass those variables to post script
                    km_post = km
                    ud_post = userDir
                    tf_post  = tf
                    conf_post = conf
                    created_before = false

                    if ("${params.Operation}" == "--create") {
                        if(!userDir.IsNewMachine()){
                            created_before = true
                            error("It seems that there are actually resources with that name.\nPlease destroy them first or use if you just forgot about them. :)")
                        } else {
                            tf.CreateMachine(userDir, km, conf, steps)
                        }
                    } else if ("${params.Operation}" == "--destroy") {
                        tf.DestroyMachine(userDir, km, conf, steps)
                    } else if ("${params.Operation}" == "--delete-machine-dir") {
                        userDir.DeleteMachineDirectory()
                    }
                }
            }
            post {
                success {
                    script {
                        if ("${params.Operation}" == "--create") {
                            keys = km_post
                            keys.DeleteKeys()
                        }
                    }
                }
                failure {
                    script {
                        if ("${params.Operation}" == "--create" && params.destroy_if_failed == "yes" && created_before == false) {
                            userDir = ud_post
                            km = km_post
                            conf = conf_post
                            tf.DestroyMachine(userDir, km, conf, steps)
                        }
                    }
                }
            }
        }
    }
}
