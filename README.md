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