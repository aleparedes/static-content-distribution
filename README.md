# Terraform module to distribute static content.
This repo contains a terraform module to distribute static content from one bucket for /static/ paths, and as default to serve a simple 'hello-world' javascript SPA application from a different bucket. 
Some considerations:
- The distribution is only accessible for certain IP ranges.
- The ARN of the ACM certificate is taken as a parameter.
- S3 bucket are created with best practices configuration.
- A Route53 HostedZone is created
- A CloudFront web distribution is created.
- Relevant DNS entries pointing to the distribution are created.
- An IP protection is implemented.
- A basic authentication protection for the distribution is implemented (static username + password).
- Documentation of how to deploy and run is provided.
- Testing is included.

## Repository Structure
This repository is structured as follows:
```shell
.
├── .gitignore                  -> ignored files
├── README.md                   -> this readme file
├── doc                         -> documentation folder
│   ├── architecture.png        -> rendered achitecture diagram 
│   └── architecture.puml       -> PlantUML architecture diagram
└── terraform                   -> terraform files
    ├── config.tf               -> terraform configuration variables
    └── storage.tf              -> storage deployment file
```
## Architecture
![Architecture](doc/architecture.png?raw=true)
### S3 Buckets
- Private
- Versioned
- Encrypted
- Logging enabled

## Prerequisites
Before you start, you need the following:
- AWS Command Line Interface installed and configured with the AWS environment you want to deploy to
- Terraform installed
- This repository cloned
### Configuration
Edit the *terraform/config.tf* and set you desired configuration for:
- **Application bucket name**: The name of the bucket that stores the application.
- **Force destroy bucket**: A boolean that indicates if all objects should be deleted from the bucket, so that the bucket can be destroyed without error. These objects are _not_ recoverable.
- **Resource owner email**: All deployable resources contains a tag *"owner"* for easy finding of the deployed resources in the cloud. 

*Note: These configuration variables could also be set on deployment time by using the --var option in the terraform plan and apply commands. Example:*
```terraform plan -var="resource_owner_email=aldo.osorio@sarasa.com"```

## Deployment
Run the following commands in the "terraform" folder to deploy the infrastructure:
```terraform init```
```terraform plan```
```terraform apply``` 
After these steps the infrastructure should be successfully deployed. 

*Note: You can do a quick check by querying all resources that contain the tag "owner" previously defined.  Example:*
```aws resourcegroupstaggingapi get-resources --tag-filters Key=owner,Values=aldo.osorio@sarasa.com --tags-per-page 100```

## Cleanup
Run the following commands to cleanup the infrastructure:
```terraform destroy```

  


