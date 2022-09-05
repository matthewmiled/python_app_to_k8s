# Project Configuration

### Pipenv

Pipenv is used for package management. The Pipfile is located in the root directory.
The project uses python 3.8.

### Python Source Code

Stored within `src`, which is within the root directory. When the container/application is executed, it looks for the `__main__.py` module within `src`. If this needs to be changed, it needs to also be reconfigured in `Dockerfile`.

### Dockerfile

Stored in the root directory. Relies on the Pipfile and source code being located in the directories stated above. 

Build the Dockerfile locally into an image using:
`docker build -t docker-test .`

Run container locally from image using:
`docker run docker-test`

The container will execute the simple print statement defined in the python `__main__.py` and exit.

___

# AWS EKS

Ref: https://www.youtube.com/watch?v=p6xDCz00TxU -> A really helpful video by 'TechWorld with Nana' on how to set up a cluster with EKS

### EKLCTL

The easiest way to set up a cluster on EKL is to use the third party CLI by Weaveworks.

https://github.com/weaveworks/eksctl

```
brew tap weaveworks/tap
brew install weaveworks/tap/eksctl
```

### Create a cluster

EKSCTL needs to authenticate with AWS, so make sure that the correct AWS credentials (access key and secret key) are saved in `~/.aws/credentials`.

Can skip this stage if you already have a cluster you just want to deploy to. 

Using `eksctl create cluster` will create a default cluster in EKS, but can also pass configuration values:

```
eksctl create cluster \
--name test-cluster  
--region us-west-2 \
--nodegroup-name linux-nodes \
--node-type t2.nano 
--nodes 2
```

This will take a while to complete (~20 mins).

Each node corresponds to an EC2 instance. You will now see the nodes and cluster listed in EKS. 

___

# AWS ECR

Elastic Container Registry is where docker images will be stored, so they can be pulled and deployed in the cluster.

Create a repository in the AWS ECR browser console. We are calling it `eks-demo`. 

Authenticate it via the AWS CLI with the following command (sub in your region and account number):

```
aws ecr get-login-password --region <YOUR_REGION>| docker login --username AWS --password-stdin <YOUR_ACCOUNT_NUMBER>.dkr.ecr.<YOUR_REGION>.amazonaws.com 
```
Once you have built the docker image for this project (see `Dockerfile` section above), you can tag the image. Recall that we called our docker image `docker-test`:

```
docker tag docker-test:latest <YOUR_ACCOUNT_NUMBER>.dkr.ecr.<YOUR_REGION>.amazonaws.com/eks-demo:latest
```

Now we can push the local image to the ECR repository:

```
docker push <YOUR_ACCOUNT_NUMBER>.dkr.ecr.<YOUR_REGION>.amazonaws.com/eks-demo:latest
```

You should now see the image in your ECR repo, with the tag `latest`.

___

# Deploying the application onto Kubernetes cluster

For this example, we're going to set up a CronJob on the cluster, that will execute our demo python app every minute. 

Amend the `cronjob.yaml` file so the image line points to the image you've just uploaded to ECR. 

Then run:

```
kubectl create -f cronjob.yaml
```

Confirm that the CronJob has been created and that jobs are scheduled to run every minute:

```
kubectl get cronjob test-cronjob
```
```
kubectl get jobs --watch
```

Every time a job runs it will create a pod. 

```
kubectl get pods
```

The pod will be prefixed with `test-cronjob` and then a random string. E.g. `test-cronjob-27706710-ttf9r`

You can check whether the pod/application/job ran successfully by checking its logs (replace the job name with a job name that outputted from the above):

```
kubectl logs test-cronjob-27706710-ttf9r
```

All the application does is print the string `Test`. So this is what you should see from the log output.

You can delete the cronjob with:

```
kubectl delete cronjob test-cronjon
```





