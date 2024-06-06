import com.cloudbees.plugins.credentials.CredentialsScope
import com.cloudbees.plugins.credentials.domains.Domain
import com.cloudbees.plugins.credentials.impl.UsernamePasswordCredentialsImpl
import com.cloudbees.plugins.credentials.SystemCredentialsProvider
import hudson.util.Secret

def domain = Domain.global()
def store = SystemCredentialsProvider.getInstance().getStore()

def githubUsername = System.getenv("GH_USERNAME")
def githubToken = System.getenv("GH_TOKEN")
def githubCredentialsId = System.getenv("GH_CRED_ID")

def githubCredentials = new UsernamePasswordCredentialsImpl(
    CredentialsScope.GLOBAL,
    githubCredentialsId,
    "GitHub credentials",
    githubUsername,
    githubToken
)

def dockerUsername = System.getenv("DH_USERNAME")
def dockerToken = System.getenv("DH_TOKEN")
def dockerCredentialsId = System.getenv("DH_CRED_ID")

def dockerCredentials = new UsernamePasswordCredentialsImpl(
    CredentialsScope.GLOBAL,
    dockerCredentialsId,
    "Docker Hub credentials",
    dockerUsername,
    dockerToken
)

store.addCredentials(domain, githubCredentials)
store.addCredentials(domain, dockerCredentials)

println "GitHub and Docker Hub credentials added successfully"