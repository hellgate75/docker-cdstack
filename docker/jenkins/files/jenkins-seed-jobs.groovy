#!groovy

def hostProjPath = '/jenkins/pipelines/projects'
def params = [CLOUD: 'local', REGION: '', REGISTRY: 'lbgvanilla', HOST_PROJECT_PATH: hostProjPath, INT_DOMAIN: 'riglet']
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
job('_create_dls_2s_project') {
    parameters {
        stringParam('name', '', 'Project Name')
        stringParam('gitUrl', 'https://github.com/myaccout/myrepo.git', 'Git/Bitbucket Repository URL')
        stringParam('branchToBuild', 'master', 'Branch(es) to build')
        stringParam('stagingPipeline', 'pipelines/staging.groovy', 'Staging jobdsl pipeline definition path')
        stringParam('prodPipeline', 'pipelines/prod.groovy', 'Prod pipeline jobdsl definition path')
    }
    steps {
        dsl {
          text("if(stagingPipeline) pipelineJob(name+'-staging') {triggers {scm('H/5 * * * *')}; definition {cpsScm {scm {git {branch(branchToBuild);remote {url(gitUrl)}}}; scriptPath(stagingPipeline)}}}; ")
        }
        dsl {
          text("if(prodPipeline) pipelineJob(name+'-prod') { definition { cpsScm { scm {git {branch(branchToBuild);remote {url(gitUrl)}}}; scriptPath(prodPipeline)}}}; ")
        }
    }
}
'''
def workspace = new File('.')
def jobManagement = new JenkinsJobManagement(System.out, [:], workspace)
new DslScriptLoader(jobManagement).runScript(seedJob)
def seedJob = '''
job('_create_dls_1s_project') {
    parameters {
        stringParam('name', '', 'Project Name')
        stringParam('gitUrl', 'https://github.com/myaccout/myrepo.git', 'Git/Bitbucket Repository URL')
        stringParam('branchToBuild', 'master', 'Branch(es) to build')
        stringParam('pipeline', 'pipeline.groovy', 'Pipeline jobdsl definition path')
    }
    steps {
        dsl {
          text("if(stagingPipeline) pipelineJob(name+'-pipeline') {triggers {scm('H/5 * * * *')}; definition {cpsScm {scm {git {branch(branchToBuild);remote {url(gitUrl)}}}; scriptPath(pipeline)}}}; ")
        }
    }
}
'''
'''
def workspace = new File('.')
def jobManagement = new JenkinsJobManagement(System.out, [:], workspace)
new DslScriptLoader(jobManagement).runScript(seedJob)
def seedJob = '''
job('_create_jnks_project') {
    parameters {
        stringParam('name', '', 'Project Name')
        stringParam('gitUrl', 'https://github.com/myaccout/myrepo.git', 'Git/Bitbucket Repository URL')
        stringParam('branchToBuild', 'master', 'Branch(es) to build')
        stringParam('jenkinsFile', 'Jenkinsfile', 'Jeninsfile definition path')
    }
    steps {
        dsl {
          text("if(stagingPipeline) pipelineJob(name+'-pipeline') {triggers {scm('H/5 * * * *')}; definition {cpsScm {scm {git {branch(branchToBuild);remote {url(gitUrl)}}}; scriptPath(jenkinsFile)}}}; ")
        }
    }
}
'''
