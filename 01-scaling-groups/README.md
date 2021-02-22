# Lab - Auto scaling group
## Description
Testing an AWS auto scaling group deployment with Terraform using the following modules
- [vpc](https://registry.terraform.io/modules/terraform-aws-modules/vpc/aws/latest)
- [autoscaling](https://registry.terraform.io/modules/terraform-aws-modules/autoscaling/aws/latest)
- [security-group](https://registry.terraform.io/modules/terraform-aws-modules/security-group/aws/latest)

## Lab file structure
```
├── 01-scaling-groups
│   ├── main.tf
│   ├── Makefile
│   ├── README.md
│   ├── variables.tf (need to be added. see below)
│   └── versions.tf
```

## Notes
- Version of *Terraform* used in this lab: `Terraform v0.14.7`
- Aliases of various commands are defined in a `Makefile`. Ex:
```bash
# Plan the infrastructure. The result will be saved in a file
make plan

# Create or update the declared infrastructure
make apply

# Plan and apply the project
make all
```
- The AWS credentials are loaded outside Terraform. They can be configured via environnement variables or various other methods. 
> My credentials are in the file `~/.aws/credentials`
- The Terraform state file is saved in a S3 bucket. See the file `versions.tf`. Modify the bucket and name file if needed
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
