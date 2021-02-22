# Lab - Auto scaling group
## Description
Testing an AWS auto scaling group deployment with Terraform using the following Terraform modules
- [vpc](https://registry.terraform.io/modules/terraform-aws-modules/vpc/aws/latest)
- [autoscaling](https://registry.terraform.io/modules/terraform-aws-modules/autoscaling/aws/latest)
- [security-group](https://registry.terraform.io/modules/terraform-aws-modules/security-group/aws/latest)

## Notes
- The AWS credentials are loaded outside Terraform. They can be configured via environnement variables or various other methods
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
