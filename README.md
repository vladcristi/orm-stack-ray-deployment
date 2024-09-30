# Oracle Resource Manager Stack: Ray Cluster Deployment on OCI

This Oracle Resource Manager (ORM) stack provides an easy to deploy Ray Serve with Ray Cluster into Oracle Cloud Infrastructure (OCI). Ray is a distributed computing framework that simplifies building and running large-scale machine learning and data workloads.


## Table of Contents
- [Overview](#overview)
- [Architecture](#architecture)
- [Prerequisites](#prerequisites)
- [Deployment Steps](#deployment-steps)
- [Configuration](#configuration)
- [Usage](#usage)
- [Cleaning Up](#cleaning-up)


## Overview

This stack automates the deployment of Ray cluster in OCI, leveraging OCI GPU shapes for high-performance compute tasks. The deployment includes:
- Deployment of Ray Cluster
- Deployment of Ray Serve Application into Ray Cluster
- Installation of Jupyter Notebooks into bastion host and possibility to run test.ipynb code which queries the application deployed with Ray Serve into Ray Cluster

## Architecture

- 1 Ray Head Node
- 2 Ray Worker Nodes


## Prerequisites
- You must have access to an Oracle Cloud Infrastructure tenancy and have a user which has policies to permit the use of Oracle Resource Manager, Networking, Compute and Block Volume services in OCI.

## Deployment Steps
1. Go to Resource Manager and drop the folder there, then name your deployment how you want.
2. Complete the variables needed as in the description for each.
3. Deploy the stack.
4. Select apply which will create an apply job and wait for the deployment of resources and configuration to be finished.

## Usage
Once the apply job has succeded, go to output area of the job and use the ip of the bastion to ssh into it using opc user.
Then write the following command and replace from the url "127.0.0.1" with the ip of the bastion and write the url into your browser
``` 
cat jupyter.out
```
You will see there the Jupyter Notebooks interface where you can run test.ipynb code to query the application which was deployed with Ray Serve into the Ray Cluster.

In order to access the Ray Dashboard you can take the ip of Ray Head Node from the output section of the apply job which deployed your cluster into Oracle Resource Manager and write the following url into your browser:
http://<ray_head_ip>:8265

## Cleaning Up
To cleanup the deployed infrastructure and its configuration select destroy job from Oracle Resource Manager.