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

func TestStorage(t *testing.T) {
    // Arrange ------------------------------------------------
    t.Parallel()
    
    expectedApplicationBucketName := fmt.Sprintf("application-bucket-test-%s", strings.ToLower(random.UniqueId()))
    expectedStaticContentBucketName := fmt.Sprintf("static-content-bucket-test-%s", strings.ToLower(random.UniqueId()))
    expectedOwner := "test@zoi.de"
    
    terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
        TerraformDir: "../",
        Vars: map[string]interface{}{
            "application_bucket_name": expectedApplicationBucketName,
            "static_content_bucket_name": expectedStaticContentBucketName,
            "resource_owner_email": expectedOwner,
        },
    })
    defer terraform.Destroy(t, terraformOptions)

    // Act ------------------------------------------------
    terraform.InitAndApply(t, terraformOptions)
    
    applicationBucketID := terraform.Output(t, terraformOptions, "application_bucket_id")
    applicationBucketREGION := terraform.Output(t, terraformOptions, "application_bucket_region")
    applicationBucketVersioning := aws.GetS3BucketVersioning(t, applicationBucketREGION, applicationBucketID)
    staticContentBucketID := terraform.Output(t, terraformOptions, "static_content_bucket_id")
    staticContentBucketREGION := terraform.Output(t, terraformOptions, "static_content_bucket_region")
    staticContentBucketVersioning := aws.GetS3BucketVersioning(t, staticContentBucketREGION, staticContentBucketID)
    staticContwntDistributionLogBucketID := terraform.Output(t, terraformOptions, "static_content_distribution_log_bucket_id")
    staticContwntDistributionLogBucketREGION := terraform.Output(t, terraformOptions, "static_content_distribution_log_bucket_region")
    staticContwntDistributionLogBucketVersioning := aws.GetS3BucketVersioning(t, staticContwntDistributionLogBucketREGION, staticContwntDistributionLogBucketID)


    // Assert ------------------------------------------------
    assert.Equal(t, applicationBucketID, expectedApplicationBucketName)
    assert.Equal(t, applicationBucketVersioning, "Enabled")
    assert.Equal(t, staticContentBucketID, expectedStaticContentBucketName)
    assert.Equal(t, staticContentBucketVersioning, "Enabled")
    assert.Equal(t, staticContwntDistributionLogBucketID, "static-content-distribution-logs")
    assert.Equal(t, staticContwntDistributionLogBucketVersioning, "")
    assert.Equal(t, expectedOwner, "test@zoi.de")
}