package test

import (
    "fmt"
    "strings"
    "testing"
    "github.com/gruntwork-io/terratest/modules/random"
    "github.com/gruntwork-io/terratest/modules/terraform"
    "github.com/stretchr/testify/assert"
    "github.com/gruntwork-io/terratest/modules/aws"
)

var expectedApplicationBucketName = fmt.Sprintf("application-bucket-test-%s", strings.ToLower(random.UniqueId()))
var expectedStaticContentBucketName = fmt.Sprintf("static-content-bucket-test-%s", strings.ToLower(random.UniqueId()))
var expectedOwner = "alejandro.paredes@zoi.de"
var expectedCertificateArn = "arn:aws:acm:us-east-1:733412096037:certificate/918276dc-e1d8-46df-a8f7-e8065efc9c83"

func TestDistribution(t *testing.T) {
    // Arrange ------------------------------------------------
    t.Parallel()
    
    terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
        TerraformDir: "../terraform",
        Vars: map[string]interface{}{
            "application_bucket_name": expectedApplicationBucketName,
            "static_content_bucket_name": expectedStaticContentBucketName,
            "resource_owner_email": expectedOwner,
            "certificate_arn": expectedCertificateArn,
        },
    })
    // The destroy is done manyally as the cloudfront and the lambda (@edge) 
    // are replicated resources, the destroy of them may take some time. 
    // Retry the destoy after a while...
    // defer terraform.Destroy(t, terraformOptions)

    // Act ------------------------------------------------
    terraform.InitAndApply(t, terraformOptions)
    
    applicationBucketID := terraform.Output(t, terraformOptions, "application_bucket_id")
    applicationBucketREGION := terraform.Output(t, terraformOptions, "application_bucket_region")
    applicationBucketVersioning := aws.GetS3BucketVersioning(t, applicationBucketREGION, applicationBucketID)
    staticContentBucketID := terraform.Output(t, terraformOptions, "static_content_bucket_id")
    staticContentBucketREGION := terraform.Output(t, terraformOptions, "static_content_bucket_region")
    staticContentBucketVersioning := aws.GetS3BucketVersioning(t, staticContentBucketREGION, staticContentBucketID)
    staticContwntDistributionLogBucketID := terraform.Output(t, terraformOptions, "logs_bucket_id")
    staticContwntDistributionLogBucketREGION := terraform.Output(t, terraformOptions, "logs_bucket_region")
    staticContwntDistributionLogBucketVersioning := aws.GetS3BucketVersioning(t, staticContwntDistributionLogBucketREGION, staticContwntDistributionLogBucketID)
    cloudfrontDomainName := terraform.Output(t, terraformOptions, "cloudfront_domain_name")
    hostnames := terraform.Output(t, terraformOptions, "hostnames")
    functionName := terraform.Output(t, terraformOptions, "function_name")
    functionRoleName := terraform.Output(t, terraformOptions, "function_role_name")

    // Some Storage Asserts------------------------------------------------
    assert.Equal(t, applicationBucketID, expectedApplicationBucketName)
    assert.Equal(t, applicationBucketVersioning, "Enabled")
    assert.Equal(t, staticContentBucketID, expectedStaticContentBucketName)
    assert.Equal(t, staticContentBucketVersioning, "Enabled")
    assert.Equal(t, staticContwntDistributionLogBucketID, "static-content-distribution-logs")
    assert.Equal(t, staticContwntDistributionLogBucketVersioning, "")

    // Some Networking and Content Delivery Asserts------------------------------------------------
    assert.Equal(t, true, strings.Contains(cloudfrontDomainName, ".cloudfront.net"))
    assert.Equal(t, hostnames, "[sarasa.ga]")

    // Some Compute Asserts------------------------------------------------
    assert.Equal(t, functionName, "static_content_distribution_authorizer")
    assert.Equal(t, functionRoleName, "service_role")
}