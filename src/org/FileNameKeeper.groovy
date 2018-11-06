#!groovy

package org

class FileNameKeeper {

    FileNameKeeper() {}

    private String daemon
    private String tfVars
    private String tfMain
    private String prepareTemplate

    // Names of files loaded from parameters.
    private String userInstance
    private String userPubKey
    private String userPrivKey

    // Names of files used as default in case if user files do not exist.
    private String defaultInstance
    private String defaultPubKey
    private String defaultPrivKey

    // Names of files ready to use.
    private String mainInstance
    private String mainPubKey
    private String mainPrivKey

    public void setDaemonName(name) {
        this.daemon = name
    }

    public void setTfVarsName(name) {
        this.tfVars = name
    }

    public void setTfMainName(name) {
        this.tfMain = name
    }

    public void setPrepareTemplateName(name) {
        this.prepareTemplate = name
    }

    public void setUserInstanceName(name) {
        this.userInstance = name
    }

    public void setUserPubKeyName(name) {
        this.userPubKey = name
    }

    public void setUserPrivKeyName(name) {
        this.userPrivKey = name
    }

    public void setDefaultInstanceName(name) {
        this.defaultInstance = name
    }

    public void setDefaultPubKeyName(name) {
        this.defaultPubKey = name
    }

    public void setDefaultPrivKeyName(name) {
        this.defaultPrivKey = name
    }

    public void setMainInstanceName(name) {
        this.mainInstance = name
    }

    public void setMainPubKeyName(name) {
        this.mainPubKey = name
    }

    public void setMainPrivKeyName(name) {
        this.mainPrivKey = name
    }

    public String daemonName() {
        return this.daemon
    }

    public String tfVarsName() {
        return this.tfVars
    }

    public String tfMainName() {
        return this.tfMain
    }

    public String prepareTemplateName() {
        return this.prepareTemplate
    }

    public String userInstanceName() {
        return this.userInstance
    }

    public String userPubKeyName() {
        return this.userPubKey
    }

    public String userPrivKeyName() {
        return this.userPrivKey
    }

    public String defaultInstanceName() {
        return this.defaultInstance
    }

    public String defaultPubKeyName() {
        return this.defaultPubKey
    }

    public String defaultPrivKeyName() {
        return this.defaultPrivKey
    }

    public String mainInstanceName() {
        return this.mainInstance
    }

    public String mainPubKeyName() {
        return this.mainPubKey
    }

    public String mainPrivKeyName() {
        return this.mainPrivKey
    }
}