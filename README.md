# diamond
## DevOps challenge

**the challenge:**  
Write	an	Ansible	playbook	that	builds	and	runs	a	Docker	container	for	a	coin	daemon	of	your	choice

**crushing it / extra points for:**
* Compile	the	coin	from	scratch
* Perform	cryptographic	verification	of	the	code/binary	checksums/signatures
* Use	Amazon	EC2
* Build	on	Project	Atomic	for	the	OS
* Add	to/deploy	from	a	Docker	registry
* Leverage	Kubernetes	for	container	orchestration
* Use	ansible-container       

**guidance:**
* please provide a link to github repo (or whatever repo service you prefer)
* they will be cloning the repo and running it locally following the instructions you provide
* don't make assumptions about the environment, they will test it in several different environments

## Approach

Time to turn something in...

I chose Diamond `DMDcoin` because there was some existing work on dockerizing the build. It was
a starting point... Chasing and working around several bugs burned a
lot of time that could have gone toward experimenting with other coin daemons.
Currently, the Docker build in this repository clones the original coin daemon
source code from another repo. I would expect to use a direct fork of the deamon
code into this project's sources if I do further work on it.

I used components that I knew would fit into a CD pipeline but didn't provide the
pipeline orchestration. So, the developer uses Maven for building the versioned
artifacts (e.g. application components and deployment packages). In this project,
the Docker image is one of the Maven artifacts. The Maven artifacts are registered
in a JFrog Artifactory Cloud instance and the Docker image ends up in an AWS ECS
(Docker) registry. I would likely move the Docker registry to Artifactory as well
to put all production artifacts in the same place (and using the same auth/e/o).

The deployment artifact (diamond-ansible-deploy) contains the commands and 
Ansible configuration to setup the host and install/run the application container.
For what it's worth, when using an end-to-end orchestration system (i.e. Jenkins V2
using Pipeline), both Maven and Ansible would be invoked from the pipeline.

## Developer Requirements

* Maven 3.3+ (with `settings.xml` in developer's ```~/.m2``` directory)
* Docker recent (with daemon running)
* Ansible recent
* Git
* AWS CLI

The Artifactory account credential is in the `settings.xml` file. The AWS keys for
AWS ECR access are also needed in the user's environment. Those credentials have been sent separately.

   *Note: I can provide console access to the account if you want it.*

One last thing on the build side... AWS provides a CLI that will give you the docker
login command string. The bad part is that docker login messes up the entry it makes
in the user's `~/.docker/config.json` file (bug) and the token expires in about an hour.

Here are the commands (for Linux and Mac) to get the docker login string, run it, and
correct the the docker credential entry:

```bash
eval $(aws ecr get-login --no-include-email --region us-west-2)
sed -E -i.bak 's#[0-9]{12}[.]dkr[.]ecr[.]#https://&#' ~/.docker/config.json
```

## Run the pipeline

### Build

```bash
cd /to/the/top/of/the/repo/clone
mvn -B -U clean deploy
```

### Get host instance

Some more time and this would have been automated in AWS CloudFormation. Sigh...

I used the AWS EC2 console to launch an instance:
* Debian : Jessie Linux OS
* t2.large (2 core, 16GB RAM)
* assigned a public IP
* with a role that has permissions for writing in the ECS registry
    - used AWS managed policy, AmazonEC2ContainerRegistryPowerUser
* 50 GB storage
* security group allowing:
    - inbound access for TCP port 22 (my IP only) and possibly TCP port 17772 (I'm not doing it)
    - outbound access to anywhere
* SSH key-pair (you will need the secret key)
  
### Configure host and install container

There are many ways to get the Ansible build artifact from Artifactory but a console
session is pretty easy (credential and URL sent separately).

Click on `Artifacts` in the left sidebar. The path to the artifact is
`libs-release-local/meine/challenge/diamond-ansible-deploy/1.1/diamond-ansible-deploy-1.1.zip`

You can also use curl or wget (with credential) for
`https://acrogecko.jfrog.io/acrogecko/libs-release-local/meine/challenge/diamond-ansible-deploy/1.1/diamond-ansible-deploy-1.1.zip`

Unzip the artifact.

Edit `hosts` and put in the correct host IP.

Look at `ansible.sh` 
- You may run the first command (with the proper keypair file path) to see if Ansible is happy.
- Run the second command (with the proper keypair file path) to deploy the coin daemon.
  
## Questions

Wow, that's a pile of stuff! :-)

I'll take questions now...
