import hudson.FilePath
import hudson.model.ParametersAction
import hudson.model.FileParameterValue
import hudson.model.Executor

// This code is a workaround for file parameters in pipeline
// https://bitbucket.org/janvrany/jenkins-27413-workaround-library

def call(String name, String fname = null) {
    def paramsAction = currentBuild.rawBuild.getAction(ParametersAction.class);
    if (paramsAction != null) {
        for (param in paramsAction.getParameters()) {
            if (param.getName().equals(name)) {
                if (! param instanceof FileParameterValue) {
                    error "unstashParam: not a file parameter: ${name}"
                }
                if (env['NODE_NAME'] == null) {
                    error "unstashParam: no node in current context"
                }
                if (env['WORKSPACE'] == null) {
                    error "unstashParam: no workspace in current context"
                }
                if (param.getOriginalFileName() == "") {
                    return "";
                }
                nodeName = env['NODE_NAME'] == 'master' ? '(master)' : env['NODE_NAME']
                workspace = new FilePath(Jenkins.getInstance().getComputer(nodeName).getChannel(), env['WORKSPACE'])
                filename = fname == null ? param.getOriginalFileName() : fname
                file = workspace.child(filename)
                file.copyFrom(param.getFile())
                return filename;
            }
        }
    }
    error "unstashParam: No file parameter named '${name}'"
}