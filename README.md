## My Personal Terraform AWS Modules

This repo is for personal use, and I'm exposing modules to the AWS resources I frequently need for demos, or for consulting work.

This setup follows good practices and high security standards, and can be adapted for production workloads.

## The modules

**VPC Module** - Helps create a VPC with 2 or 3 subnets and its default routes :
* public - with an internet gateway
* private - with a NAT gateway
* isolated - for DBs. Traffic only accessible from the same VPC

**DNS Module** - Will help create a subdomain by performing a delegation of authority on an existing domain (assuming Domain APEX is in the same AWS account), along with its TLS certs with ACM.

**EKS Module** - Will provision a cluster with the following pre-configured plugins and helm charts:
* vpc-cni
* coredns
* kube-proxy
* eks-pod-identity-agent
* aws-load-balancer-controller
* external-dns
* karpenter

Other Helm Charts, such as metrics-server, EBS CSI controllers, and more, can be installed as needed.

WIP - Support OIDC and pod identity resources from public helm charts. 
Additionally, EKS module provides an easy way to create pod identity mappings for Application level resources.


**ECR Module** - Creates container image repositories passed as a list of elements.



## Sample resulting high level diagram  

<img width="1484" height="681" alt="eks-vpc-diagram" src="https://github.com/user-attachments/assets/4079ae64-2469-4824-a244-4fcce733efbb" />
