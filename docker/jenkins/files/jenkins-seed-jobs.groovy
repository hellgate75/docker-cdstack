#!groovy

def hostProjPath = '/jenkins/pipelines/projects'
def params = [CLOUD: 'local', REGION: '', REGISTRY: 'cddocker', HOST_PROJECT_PATH: hostProjPath, INT_DOMAIN: 'cdnet']
def nodeProps = jenkins.model.Jenkins.getInstance().getGlobalNodeProperties()
def envVars = nodeProps.get(hudson.slaves.EnvironmentVariablesNodeProperty)
if (envVars == null) {
  envVars = new hudson.slaves.EnvironmentVariablesNodeProperty()
  nodeProps.add(envVars)
}
envVars.envVars << params

// register pipeline library
import jenkins.plugins.git.GitSCMSource
import org.jenkinsci.plugins.workflow.libs.GlobalLibraries
import org.jenkinsci.plugins.workflow.libs.LibraryConfiguration
import org.jenkinsci.plugins.workflow.libs.SCMSourceRetriever
def pipelines = new LibraryConfiguration("jenkinsfy",
                          new SCMSourceRetriever(
                                  new GitSCMSource(
                                          "git", "https://github.com/hellgate75/jenkins-pipeline-libraries.git",
                                          null, "*", null, true)))
pipelines.defaultVersion = 'master'
GlobalLibraries.get().setLibraries([pipelines])

// create seed job
import javaposse.jobdsl.dsl.DslScriptLoader
import javaposse.jobdsl.plugin.JenkinsJobManagement
def seedJob = '''
job('_create_2p_project') {
    concurrentBuild(false)
    parameters {
        stringParam('name', '', 'Project Name')
        stringParam('credentialsRef', 'base_credentials', 'Reference to Jenkins credentials (default: base_credentials)')
        stringParam('gitUrl', 'https://github.com/myaccout/myrepo.git', 'Git/Bitbucket Repository URL')
        stringParam('branchToBuild', 'master', 'Branch(es) to build')
        stringParam('stagingPipeline', 'pipelines/staging/Jenkinsfile', 'Staging jobdsl(groovy)/Jenkinsfile pipeline script definition path')
        stringParam('prodPipeline', 'pipelines/prod/Jenkinsfile', 'Prod jobdsl(groovy)/Jenkinsfile pipeline script definition path')
    }
    steps {
        dsl {
          text("if(stagingPipeline) pipelineJob(name+'-staging') { definition {cpsScm {scm {git {branch(branchToBuild);remote {credentials(credentialsRef);url(gitUrl)}}}; scriptPath(stagingPipeline)}}}; ")
        }
        dsl {
          text("if(prodPipeline) pipelineJob(name+'-production') { definition { cpsScm { scm {git {branch(branchToBuild);remote {credentials(credentialsRef);url(gitUrl)}}}; scriptPath(prodPipeline)}}}; ")
        }
    }
}
'''
def workspace = new File('.')
def jobManagement = new JenkinsJobManagement(System.out, [:], workspace)
new DslScriptLoader(jobManagement).runScript(seedJob)
def seedJob2 = '''
job('_create_1p_project') {
    concurrentBuild(false)
    parameters {
        stringParam('name', '', 'Project Name')
        stringParam('credentialsRef', 'base_credentials', 'Reference to Jenkins credentials (default: base_credentials)')
        stringParam('gitUrl', 'https://github.com/myaccout/myrepo.git', 'Git/Bitbucket Repository URL')
        stringParam('branchToBuild', 'master', 'Branch(es) to build')
        stringParam('pipeline', 'pipelines/Jenkinsfile', 'jobdsl(groovy)/Jenkinsfile pipeline script definition path')
    }
    steps {
        dsl {
          text("if(pipeline) pipelineJob(name+'-pipeline') {definition {cpsScm {scm {git {branch(branchToBuild);remote {credentials(credentialsRef);url(gitUrl)}}}; scriptPath(pipeline)}}}; ")
        }
    }
}
'''
def workspace2 = new File('.')
def jobManagement2 = new JenkinsJobManagement(System.out, [:], workspace2)
new DslScriptLoader(jobManagement2).runScript(seedJob2)
