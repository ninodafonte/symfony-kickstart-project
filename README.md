# Symfony Kickstart Template  
**All included: Docker + AWS + Github Actions for CI/CD**

This project provides a template where you get the needed components to provision:

| **Feature**   | **Description** |
| --------- |:------------|
| Local Environment | A local development environment for your Symfony 5 application using a two-tier architecture (webserver + DB). |
| Remote Environment | A remote environment on the AWS Cloud with exactly the same configuration. |
| CI/CD | A pre-configured CI/CD environment for Github + EC2 through CodeDeploy. |

![Final result - diagram](https://dafonte-dev-static.s3-eu-west-1.amazonaws.com/skp-overview.png "Diagram of what you get with this project")

Here in this [blog post](https://dafonte.dev/kickstart-symfony-project-dev-and-production-in-20-minutes), you'll find all the details about the "why" and "how" of this project so if you want to know more, or you run into trouble using it, please refer to that page to make sure you know the details.  

I'll keep in this README the necessary steps to have the environments running leaving the detailed explanation and customizations in the [blog post](https://dafonte.dev/kickstart-symfony-project-dev-and-production-in-20-minutes).

## My opinionated approach

I wanted to have **exactly** the same environment in my local machine and the remote server. That's a must for me.

I wanted to be able to customize the project once it's up and running because all the projects are quite close but not the same.

I can live with some trade-offs:

* Using ubuntu/apache / PHP is probably not the best performance you could have (please don't start with the apache-Nginx-PHP-fpm flame wars right now...) but it does the job and it's reliable for small experiments.
* The infrastructure is designed without high availability at the beginning. You could implement that customizing the scripts later on. For experiments and tests is something I don't care enough yet.

So, I decided to build it in this way:

### Local environment

* Docker images created with Packer, using ansible playbooks and managed by a docker-compose.yml file:

	* Webserver playbooks: common utils, apache, php7.4, self-signed certificate, Http, https-enabled.
	* Db server playbooks: common utils, MySQL, and a pre-created database with a specific user to play around.

### Remote environment

* Terraform scripts to create the needed infrastructure in AWS:

	* Webserver: EC2 machine provisioned using the same ansible playbooks than in development + CodeDeploy agent.
	* Dbserver: EC2 machine, again, same playbooks than in development.
	* Elastic IP pointing to the webserver to have a static IP to access.
	* It's VPC and subnet to not mess with your other AWS resources.
	* CodeDeploy application to enable the deployment from Github.
	* S3 bucket to host the code from your Github repository (explained in the following section).

### Continuous integration

* Preconfigured Github deployment with AWS CodeDeploy:

	* Once you run the Github action your code is moved to a bucket in S3
	* Github creates a new deployment in AWS.
	* CodeDeploy takes control and uses the installation scripts (provided as well) to customize the deployment of your Symfony app (migrations, dump-env and so on)

## What do you get at the end

Once everything is configured (if you follow the guide, it will take you probably around 20-30 minutes for the whole process), your development process gets very simple:

* Start your dev environment `docker-compose start`
* Code the hell out of it and push your code to your Github repo.
* Wait a few minutes while your code is transferred to your AWS instance.
* Check it online
* Go back to the second bullet point 💁

## Get your repo from this template

* Create your repo from the "Use this template" button at the top of this repo.
* Clone it into your local computer.

Make sure you have the following tools installed and configured:

* [Docker](https://docs.docker.com/get-docker/)
* [Packer](https://learn.hashicorp.com/packer/getting-started/install)
* [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-install.html)
* [Terraform](https://learn.hashicorp.com/terraform/getting-started/install.html)
* [Ansible](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html)

### Build your local environment

Create the docker images, provisioned with your ansible playbooks. Go to the /automation/packer folder you'll find in the project:

	cd automation/packer

Create the web server docker image (it will be called spk_local/webserver:latest)

	packer build create_docker_image_webserver.json

Create the dbserver docker image (it will be called spk_local/dbserver:latest)

	packer build create_docker_image_dbserver.json
	
Go back to your root folder and start your docker environment (in the background). If it's the first time you run it, the images have to be created:

	docker-compose -d up

For the next time, unless you want to create and destroy your containers all the time, I'd simply use:

	docker-compose start
	
Or (to stop them)

	docker-compose stop

The webserver image mounts your current folder as the webroot so the Symfony app included in the template should be up and running (remember you need to run `composer install` to get your dependencies first!). The ports from Apache are map by default to your 80 and 443 ports so just check localhost and should be there:

	https://localhost
	
### Build your AWS environment 

Configure the parameters needed to connect to your AWS profile and some variables you'll need to create the whole infrastructure:

	cd automation/terraform

Create your own local configuration parameters:

    cp terraform.tfvars.example terraform.tfvars
    
Configure in `terraform.tfvars` the needed variables:

    # AWS usage and connection related configuration
    aws_profile = "myAWSProfileName"
    region      = "eu-west-1"
    public_key  = "~/.ssh/somePublicKey.pub"
    private_key = "~/.ssh/somePrivateKey.pem"
    
    # EC2 base configuration (using ami for ubuntu 18.04 in eu-west-1
    ec2_size         = "t2.micro"
    amis             = {
      "eu-west-1" = "ami-089cc16f7f08c4457"
    }
    ansible_user     = "ubuntu"
    application_name = "myApplication"
    
    # Networking configuration
    cidr_vpc             = "10.1.0.0/16"
    cidr_subnet          = "10.1.0.0/24"
    webserver_private_ip = "10.1.0.10"
    dbserver_private_ip  = "10.1.0.20"
    
    # S3 bucket name for continuous integration (used by CodeDeploy to transfer files from Github)
    deployment_s3_bucket = "your-unique-bucket-name-spk-deployment"

If there is any doubt about any of these parameters please take a look at the [blog post](https://dafonte.dev/kickstart-symfony-project-dev-and-production-in-20-minutes) mentioned above, there is an in-deep explanation of the whole system.

Once you get the correct values in there, just launch the terraform process to get them created.
The first time you'll need to initialize the terraform state and libraries:

    terraform init
    
Then, you can just run the `plan` to see what's going to happen before it happens:

    terraform plan
    
And finally, apply the changes and get your infrastructure created:

    terraform apply
    
It will take a few minutes as terraform will need to create your network infrastructure, the EC2 machines, and run the ansible playbooks in both of them.
At the end of the process, you'll get output from terraform with the data you need to access your new shiny webserver.

Be aware, depending on your AWS account, you could be incurring on charges for the EC2 machines while they are running so make sure to stop them or remove the whole infrastructure once it's not useful anymore:

    terraform destroy
    
### Continuous integration/deployment

Included with the terraform scripts you applied to create the AWS infrastructure, there are included a few extra things to enable continuous integration in the system.
Basically, a CodeDeploy application has been created, a deployment group (with your new ec2 web server in it) and a S3 bucket to host the code as an intermediate step between Github and your EC2 instance.

In the [blog post](https://dafonte.dev/kickstart-symfony-project-dev-and-production-in-20-minutes) you'll find the detailed explanation about how this works but here's what you need to know in order to enable continuous integration in your repo.

There is a Github deploy already configured for you in the project. The only thing you need is to create some secrets in your repo settings:

    AWS_ACCESS_KEY_ID (access key of the user you want to use to deploy the code)
    AWS_SECRET_ACCESS_KEY (secret key for that user)                                                         
    AWS_REGION (region you are using in AWSI)
    APPLICATION_NAME (the same you've configured in terraform.tfvars)
    AWS_S3_DEPLOYMENT_BUCKET (the same you've configured in terraform.tfvars)
    
Make sure your AWS user have S3 and CodeDeploy permissions assigned in IAM (If you don't know what I'm talking about, you can always use an IAM user created with AmazonS3FullAccess and AWSCodeDeployFullAccess policies and ready to go)  

Finally, in your project, you'll see the `.github` folder and a yml file where you can decide if you want to deploy clicking a button or after every commit.
Just use `on: workflow_dispatch` or `on: push`.

My preferred way is both, so I can always run it manually but at the same time, it's deployed with every commit `on: [push, workflow_dispatch]`    

For the last step of the deployment, feel free to modify the scripts you'll find in the `build-scripts` folder. These are controlled by CodeDeploy and hooked into the process. I've included a couple of them as examples, but you can customize them or even add more steps. 
## Next steps

Some things I have in mind to improve and extend this template:

* Add an optional subdomain name enabler for the EC2 web server. If you have some domain hosted in route53, it will be pretty easy to create a subdomain, pointing it to your elastic ip and even create a let's encrypt certificate for ssl.
* Find a way to centralize configuration. Now there is some configuration in terraform.tfvars, some other stuff in the github ci/cd piece, some other in ansible. It would be nice to have some command line script to ask you a few things and generate all the stuff.
* Maybe create some more stacks ... (I'm thinking python/django stack for the next one)

## Feedback

Hope this helps some of you out there to kickstart your own experiments. Feel free to reach out and tell me what do you think about this project, feedback, advice, improvements, etc.

Happy coding! 
