#!groovy

package org

class UserDirectory {

    private String mainDirectory
    private String userDirectory
    private String machineDirectory
    private FileManager fileManager

    UserDirectory(String mainDir, String userDir, String machineDir, FileManager fm, String workspace) {
        this.mainDirectory = workspace + "/" + mainDir
        this.userDirectory = this.mainDirectory + "/" + userDir
        this.machineDirectory = this.userDirectory + "/" + machineDir
        this.fileManager = fm
    }

    public void CreateUserDirectory() {
        fileManager.NewDir(this.mainDirectory)
        fileManager.NewDir(this.userDirectory)
    }

    public void CreateMachineDirectory() {
        fileManager.NewDir(this.machineDirectory)
    }

    public void DeleteMachineDirectory() {
        fileManager.Del(this.machineDirectory)
    }

    public boolean IsNewMachine() {
        return !fileManager.Exists(this.machineDirectory)
    }

    public String MachineDir() {
        return this.machineDirectory
    }
}