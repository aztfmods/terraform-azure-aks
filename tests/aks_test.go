package main

import (
	"fmt"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"os"
	"path/filepath"
	"testing"
)

var filesToCleanup = []string{
	"*.terraform*",
	"*tfstate*",
}

type TestCase struct {
	name string
	path string
}

func getTerraformOptions(terraformDir string) *terraform.Options {
	return &terraform.Options{
		TerraformDir: terraformDir,
		NoColor:      true,
		Parallelism:  20,
	}
}

func cleanup(t *testing.T, tfOpts *terraform.Options) {
	terraform.Destroy(t, tfOpts)
	cleanupFiles(tfOpts.TerraformDir)
}

func TestApplyNoError(t *testing.T) {
	t.Parallel()

	tests := []TestCase{
		{name: "simple", path: "../examples/simple"},
		{name: "node-pools", path: "../examples/node-pools"},
		{name: "container-registry", path: "../examples/container-registry"},
		{name: "complete", path: "../examples/complete"},
	}

	for _, test := range tests {
		t.Run(test.name, func(t *testing.T) {
			terraformOptions := getTerraformOptions(test.path)

			terraform.WithDefaultRetryableErrors(t, &terraform.Options{})

			defer cleanup(t, terraformOptions)
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
