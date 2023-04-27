package test

import (
	"path/filepath"
	"testing"
  "os"
  "fmt"
	"github.com/gruntwork-io/terratest/modules/terraform"
)

var filesToCleanup = []string{
	".terraform",
	".terraform.lock.hcl",
	"terraform.tfstate",
	"terraform.tfstate.backup",
}

func TestApplyNoError(t *testing.T) {
	t.Parallel()

	tests := map[string]string{
    "simple": "../examples/simple",
    "node-pools": "../examples/node-pools",
    "container-registry": "../examples/container-registry",
    "complete": "../examples/complete", 
	}

	for name, path := range tests {
		t.Run(name, func(t *testing.T) {
			terraformOptions := &terraform.Options{
				TerraformDir: path,
				NoColor:      true,
				Parallelism:  2,
			}

			terraform.WithDefaultRetryableErrors(t, &terraform.Options{})

			defer cleanupFiles(path)
			defer func() {
        terraform.Destroy(t, terraformOptions)
        cleanupFiles(path)
			}()

			terraform.InitAndApply(t, terraformOptions)
		})
	}
}

func cleanupFiles(dir string) {
	for _, file := range filesToCleanup {
		filePath := filepath.Join(dir, file)
		fmt.Printf("Cleaning up %s\n", file)
		if err := os.RemoveAll(filePath); err != nil {
			fmt.Printf("Failed to remove %s: %v\n", filePath, err)
		}
	}
}
