
# Terraform module to distribute static content.
This repo contains a terraform module to distribute static content from one bucket for /static/ paths, and as default to serve a dummy javascript SPA application (https://startbootstrap.com/theme/freelancer) from a different bucket. 
Some considerations:
- The distribution is only accessible for certain IP ranges
- The ARN of the ACM certificate is taken as a parameter
- S3 bucket are created with best practices configuration
- A Route53 HostedZone is created
- A CloudFront web distribution is created
- Relevant DNS entries pointing to the distribution are created
- An IP protection is implemented
- A basic authentication protection for the distribution is implemented (static username + password)
- Documentation of how to deploy and run is provided
- Testing is included

## Prerequisites
Before you start, you need the following:
- AWS Command Line Interface installed and configured with the AWS environment you want to deploy to
- Terraform installed
- Go is installed
- Terratest is installed
- This repository cloned

## Configuration Variables
Edit the *terraform/config.tf* and set you desired configuration for:
- **Application bucket name**: The name of the bucket that stores the application
- **Static content bucket name**: The name of the bucket that stores the static content
- **Force destroy bucket**: A boolean that indicates if all objects should be deleted from the bucket, so that the bucket can be destroyed without error. These objects are _not_ recoverable
- **Resource owner email**: All deployable resources contains a tag *"owner"* for easy finding of the deployed resources in the cloud
- **Domain name**: External DNS domain you want to use 
- **Certificate ARN**: The ARN of the ACM certificate is taken as a parameter
- **Ip whitelist range**: The range of the allowed ips for this app

*Note: These configuration variables could also be set on deployment time by using the --var option in the terraform plan and apply commands. Example:*
```terraform plan -var="resource_owner_email=test@sarasa.com"```

## Repository Structure
This repository is structured as follows:
```
.
├── .gitignore                                  -> git ignored files
├── README.md                                   -> this readme file
├── authorizer                                  -> authorizer lambda function code
│   └── authorizer.js
├── doc                                         -> documentation and diagrams folder
│   ├── architecture.png
│   └── architecture.puml
├── html                                        -> html and static content 
│   ├── index.html
│   └── static
│       ├── assets
│       │   ├── img
│       │   │   ├── avataaars.svg
│       │   │   ├── favicon.ico
│       │   │   └── portfolio
│       │   │       ├── cabin.png
│       │   │       ├── cake.png
│       │   │       ├── circus.png
│       │   │       ├── game.png
│       │   │       ├── safe.png
│       │   │       └── submarine.png
│       │   └── mail
│       │       ├── contact_me.js
│       │       ├── contact_me.php
│       │       └── jqBootstrapValidation.js
│       ├── css
│       │   └── styles.css
│       └── js
│           └── scripts.js
├── terraform                                   -> terraform files    
│   ├── compute.tf
│   ├── config.tf                               -> configuration file
│   ├── identity-and-access-management.tf
│   ├── networking-and-content-delivery.tf
│   ├── output.tf
│   └── storage.tf
└── test                                        -> automated tests folder
    └── storage_test.go
```

## Architecture
![Architecture](doc/architecture.png?raw=true)

## Resources Details

### S3 Buckets
- Private
- Versioned
- Encrypted
- Logging enabled

### Cloudfront Distribution
- Default root object : "index.html"
- Cache enabled 

### Rout353
- Some records created with a custom domain

## Deployment
Run the following commands in the "terraform" folder to deploy the infrastructure:

```terraform init```

```terraform plan```

```terraform apply``` 

After these steps the infrastructure should be successfully deployed and the static content distribution should be accessible directly by hitting the cloudfront domain name or your custom domain name using username: test and password: test

*Note: You can also do a quick check by querying all resources that contain the tag "owner" previously defined.  Example:*

```aws resourcegroupstaggingapi get-resources --tag-filters Key=owner,Values=test@sarasa.com --tags-per-page 100```

### Cleanup
Run the following commands to cleanup the infrastructure:

```terraform destroy```

As the cloudfront and the lambda (@edge) are replicated resources, the destroy of them may take some time. Retry the destoy after a while...

## Manual Tests
Manual tests of the deplpyment were executed

## Automated Tests
Run the following commands in the "test" folder to run the infrastructure tests:

```go mod init "tests"```

```go test```

After these steps the tests should run and pass.
Consider the update of the expected tests varirables, such as the certificate ARN that you are using...

The destroy of the infrastructure should be done manyally after the test run as the cloudfront and the lambda (@edge) are replicated resources.
Run the following commands in the "terraform" folder to cleanup the infrastructure after the test run:

```terraform destroy```

and retry the destoy after a while for the replicated resources...

