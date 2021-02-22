# Lab - EKS cluster
## Description
Testing an AWS cluster deployment with Terraform using the following modules
- [vpc](https://registry.terraform.io/modules/terraform-aws-modules/vpc/aws/latest)
- [eks](https://registry.terraform.io/modules/terraform-aws-modules/eks/aws/latest)
- [security-group](https://registry.terraform.io/modules/terraform-aws-modules/security-group/aws/latest)

## Lab file structure
```
02-eks-cluster/
├── main.tf
├── Makefile
├── outputs.tf
├── README.md
├── variables.tf (needs to be added)
└── versions.tf

```
### Instructions
- `make all` to init and plan the infrastructure. As a safety mesure, applying the modifications is a different tasks.
- `make apply` to apply the modifications
- `make kubeconfig` to install the kubeconfig file
- Enter a kubectl command to confirm that the cluster is up and running
- `make destroy` to undo the lab infrastructure
```
kubectl get nodes
NAME                                         STATUS   ROLES    AGE   VERSION
ip-10-0-3-61.ca-central-1.compute.internal   Ready    <none>   14m   v1.17.12-eks-7684af
```

## Notes
- Version of *Terraform* used in this lab: `Terraform v0.14.7`
- Aliases of various commands are defined in a `Makefile`
- The AWS credentials are loaded outside Terraform. They can be configured via environnement variables or various other methods. 
> My credentials are in the file `~/.aws/credentials`
- The Terraform state file is saved in a S3 bucket. See the file `versions.tf`. Modify the bucket and name file if needed
- Once the cluster is up, here's the command in order to configure the kubeconfig file for this new cluster
```
make kubeconfig
```
- The SSH keypair configured for the EC2 instances needs to be defined in the file `variables.tf` with the following code structure :
```
variable "ssh_keypair" {
  type 	= map

  default = {
    key_name = "..."
    public_key = "..."
  }
}
```
Please modify the `key_name` and `public_key` as needed.
- Everything else is hard-coded. This code wasn't planned to be re-used outside this lab.
