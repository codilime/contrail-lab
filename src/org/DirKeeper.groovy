#!groovy

package org

class DirKeeper {

    private String mainDirectory
    private String userDirectory
    private String machineDirectory
    private String tfFilesDirectory
    private String provisionDirectory

    DirKeeper() {}

    DirKeeper(
        String mainDirectory,
        String userDirectory,
        String machineDirectory,
        String provisionDirectory,
        String tfFilesDirectory) {
        this.mainDirectory = mainDirectory
        this.userDirectory = userDirectory
        this.machineDirectory = machineDirectory
        this.provisionDirectory = provisionDirectory
        this.tfFilesDirectory = tfFilesDirectory
    }

    public String mainDir() {
        return this.mainDirectory
    }

    public String userDir() {
        return this.userDirectory
    }

    public String machineDir() {
        return this.machineDirectory
    }

    public String tfFilesDir() {
        return this.tfFilesDirectory
    }

    public String provisionDir() {
        return this.provisionDirectory
    }

    public void setMainDir(String path) {
        this.mainDirectory = path
    }

    public void setUserDir(String path) {
        this.userDirectory = path
    }

    public void setMachineDir(String path) {
        this.machineDirectory = path
    }

    public void setTfFilesDir(String path) {
        this.tfFilesDirectory = path
    }

    public void setProvisionDir(String path) {
        this.provisionDirectory = path
    }
}