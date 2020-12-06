package test

import (
    "fmt"
    "strings"
    "testing"
    "github.com/gruntwork-io/terratest/modules/random"
    "github.com/gruntwork-io/terratest/modules/terraform"
    "github.com/stretchr/testify/assert"
)

func TestStorage(t *testing.T) {
    // Arrange ------------------------------
    t.Parallel()
    
    expectedName := fmt.Sprintf("application-bucket-test-%s", strings.ToLower(random.UniqueId()))
    expectedOwner := "test@zoi.de"
    
    terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
        TerraformDir: "../",
        Vars: map[string]interface{}{
            "application_bucket_name": expectedName,
            "resource_owner_email": expectedOwner,
        },
    })
    defer terraform.Destroy(t, terraformOptions)

    // Act ------------------------------
    terraform.InitAndApply(t, terraformOptions)
    bucketID := terraform.Output(t, terraformOptions, "s3_bucket_id")

    // Assert ------------------------------
    assert.Equal(t, bucketID, expectedName)
}