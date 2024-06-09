import jenkins.model.Jenkins
import jenkins.branch.BranchSource
import org.jenkinsci.plugins.workflow.multibranch.WorkflowMultiBranchProject
import org.jenkinsci.plugins.github_branch_source.GitHubSCMSource
import org.jenkinsci.plugins.github_branch_source.BranchDiscoveryTrait
import org.jenkinsci.plugins.github_branch_source.OriginPullRequestDiscoveryTrait
import org.jenkinsci.plugins.github_branch_source.ForkPullRequestDiscoveryTrait
import org.jenkinsci.plugins.github_branch_source.ForkPullRequestDiscoveryTrait.TrustContributors
import jenkins.scm.api.trait.SCMTrait
import java.util.Arrays

// Variables
def repoOwner = 'cyse7125-su24-team15'
def repoName = 'ami-jenkins'
def githubCredentialsId = 'github'  // Replace with your GitHub credentials ID
def jobName = 'pr-validation-multibranch-pipeline'

// Get Jenkins instance
def jenkinsInstance = Jenkins.getInstance()

// Check if the job already exists
def job = jenkinsInstance.getItem(jobName)
if (job == null) {
    // Create a new Multibranch Pipeline job
    job = jenkinsInstance.createProject(WorkflowMultiBranchProject, jobName)
    println "Multibranch Pipeline job '${jobName}' created successfully."
} else {
    println "Multibranch Pipeline job '${jobName}' already exists."
}

// Configure the SCM source
def scmSource = new GitHubSCMSource(repoOwner,repoName)
scmSource.setCredentialsId(githubCredentialsId)

// Add traits to the SCM source
scmSource.setTraits(Arrays.asList(
    new BranchDiscoveryTrait(3),
    new OriginPullRequestDiscoveryTrait(2),
    new ForkPullRequestDiscoveryTrait(1, new TrustContributors())
))

// Clear any existing sources and add the new branch source
def branchSource = new BranchSource(scmSource)
job.getSourcesList().clear()
job.getSourcesList().add(branchSource)

// Set the Jenkinsfile path
job.getProjectFactory().setScriptPath('Jenkinsfile')  // Adjust if your Jenkinsfile is not in the root directory

// Save the job configuration
job.save()

println "Multibranch Pipeline job '${jobName}' configured successfully."
