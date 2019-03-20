#!groovy

package org

class TerraformManager implements Serializable {

    TerraformManager (
        String scriptFilePath, String variablesFilePath, String daemonFile, String instancesFile, String prepareInstancesFile, String runCadFile, FileManager fm
        ) {
        this.daemonFile = daemonFile
        this.instancesFile = instancesFile
        this.prepareInstancesFile = prepareInstancesFile
        this.variablesFilePath = scriptFilePath
        this.scriptFilePath = variablesFilePath
        this.runCadFile = runCadFile
        this.fileManager = fm
    }

    public void CreateMachine(UserDirectory userDir, KeyManager keys, MachineConfiguration c, steps) {
        String machineDir = userDir.MachineDir()
        userDir.CreateMachineDirectory()
        this.CopyFilesTo(machineDir)
        this.AddPermissions()
        this.RenameInstances("instances.yaml")
        boolean gotKeys = keys.PrepareKeyFiles(machineDir)

        if (!gotKeys)
            steps.error("Please provide key files first!")

        steps.sh "set +x && \
            terraform init ${machineDir} && \
            terraform apply -auto-approve  \
                -state-out=\"${machineDir}/${this.STATE_FILE_NAME}\" \
                -var='user_name='\"${c.UserName}\" \
                -var='password='\"${c.Password}\" \
                -var='project_id='\"${c.ProjectID}\" \
                -var='domain_name='\"${c.DomainName}\" \
                -var='project_name='\"${c.ProjectName}\" \
                -var='network_name='\"${c.NetworkName}\" \
                -var='branch='\"${c.Branch}\" \
                -var='ssh_key_file='\"${keys.PubKey()}\" \
                -var='ssh_private_key='\"${keys.PrivKey()}\" \
                -var='routerip='\"${c.RouterIP}\" \
                -var='flavor='\"${c.Flavor}\" \
                -var='machine_name='\"${c.MachineName}\" \
                -var='contrail_type='\"${c.ContrailType}\" \
                -var='patchset_ref='\"${c.PatchsetRef}\" \
                -var='path='\"${machineDir}\" \
                \"${machineDir}\" && \
                set -x"
    }

    public void DestroyMachine(UserDirectory userDir, KeyManager keys, MachineConfiguration c, steps) {
        String machineDir = userDir.MachineDir()
        if(!fileManager.Exists(machineDir)) {
            steps.error("The directory for this machine doesn't exist.")
        }
        if(!fileManager.Exists("${machineDir}/${this.STATE_FILE_NAME}")) {
            steps.echo("Terraform state file is missing. Deleting only directory.")
        } else {
            keys.CreateEmptyKeyFiles("id_rsa", "id_rsa.pub", machineDir)
            steps.sh " \
                set +x && \
                terraform init ${machineDir} && \
                terraform destroy -auto-approve \
                    -state=\"${machineDir}/${this.STATE_FILE_NAME}\" \
                    -var \"user_name=${c.UserName}\" \
                    -var \"password=${c.Password}\" \
                    -var \"project_id=${c.ProjectID}\" \
                    -var \"domain_name=${c.DomainName}\" \
                    -var \"project_name=${c.ProjectName}\" \
                    -var \"ssh_key_file=${machineDir}/id_rsa.pub\" \
                    -var \"ssh_private_key=${machineDir}/id_rsa\" \
                    -var \"machine_name=${c.MachineName}\" \
                    -var \"path=${machineDir}\" \
                \"${machineDir}\" && \
                set -x"
        }
        userDir.DeleteMachineDirectory()
    }

    public void CopyFilesTo(String destination) {
        String variablesName = fileManager.GetFileName(this.variablesFilePath)
        String scriptName = fileManager.GetFileName(this.scriptFilePath)
        String daemonName = fileManager.GetFileName(this.daemonFile)
        String instancesName = fileManager.GetFileName(this.instancesFile)
        String prepareInstancesName = fileManager.GetFileName(this.prepareInstancesFile)
        String runCadFile = fileManager.GetFileName(this.runCadFile)

        fileManager.Copy(this.variablesFilePath, destination + "/" + variablesName)
        fileManager.Copy(this.scriptFilePath, destination + "/" + scriptName)
        fileManager.Copy(this.daemonFile, destination + "/" + daemonName)
        fileManager.Copy(this.instancesFile, destination + "/" + instancesName)
        fileManager.Copy(this.prepareInstancesFile, destination + "/" + prepareInstancesName)
        fileManager.Copy(this.runCadFile, destination + "/" + runCadFile)

        this.variablesFilePath = destination + "/" + variablesName
        this.scriptFilePath = destination + "/" + scriptName
        this.daemonFile = destination + "/" + daemonName
        this.instancesFile = destination + "/" + instancesName
        this.prepareInstancesFile = destination + "/" + prepareInstancesName
        this.runCadFile = destination + "/" + runCadFile
    }

    public void AddPermissions() {
        "chmod 500 ${prepareInstancesFile}".execute()
    }

    public void RenameInstances(String name) {
        String location = fileManager.GetFileLocation(this.instancesFile)
        fileManager.Move(instancesFile, location + "/" + name)
        this.instancesFile = location + "/" + name
    }

    public static String STATE_FILE_NAME = "state"

    private String variablesFilePath
    private String scriptFilePath
    private String daemonFile
    private String instancesFile
    private String prepareInstancesFile
    private String runCadFile
    private FileManager fileManager
}
