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

Time to turn something in, although I could gold-plate the heck out of this...

I chose Diamond `DMDcoin` because there was some existing work on dockerizing the build. It was
a starting point... I had also expected to switch over to `litecoin` to get a smaller
blockchain and quicker initialization. Chasing and working around several bugs burned a
lot of time that could have gone to that.

I used components that I knew would fit into a CD pipeline but didn't provide the
pipeline. So, the developer uses Maven for building deployment artifacts (including
the Docker image) and Ansible is used for the host configuration and application
deployment. The Maven artifacts are registered to a JFrog Artifactory Cloud instance
and the Docker images ended up in an AWS ECS (Docker) registry. I would likely move
the Docker registry to Artifactory as well. For end-to-end orchestration, I would likely
have chosen Jenkins V2 Pipelines.

## Developer Requirements

* Maven 3.3+ (with settings.xml in developer's ~/.m2 directory)
* Docker recent (with daemon running)
* Ansible recent
* Git
* AWS CLI

The Artifactory account credential is in the settings.xml file. The AWS keys for
AWS ECR access are also needed in the user's environment. Those credentials have been sent separately.

Note: I can provide console access to the account if you want it.

One last thing on the build side... AWS provides a CLI that will give you the docker
login command string. The bad part is that docker login messes up the entry it makes
in the user's `~/.docker/config.json` file (bug) and the token expires in about an hour.

Here are the commands (for Linux and Mac) to get the docker login string, run it, and
correct the the docker credential entry:

```bash
eval $(aws ecr get-login --no-include-email --region us-west-2)
sed -E -i.bak 's#[0-9]{12}[.]dkr[.]ecr[.]#https://&#' ~/.docker/config.json
```

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
-- used AWS managed policy, AmazonEC2ContainerRegistryPowerUser
* 50 GB storage
* security group allowing:
-- inbound access for TCP port 22 (my IP only) and TCP port 17772
-- outbound access to anywhere
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
- Run the first command (with the proper keypair file path) to see if Ansible is happy.
- Run the second command (with the proper keypair file path) to deploy the coin daemon.
  
## Questions

Wow, that's a pile of stuff! :-)
I'll take questions now...
