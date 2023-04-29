package main

import (
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
	cleanupFiles(t, tfOpts.TerraformDir)
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

func cleanupFiles(t *testing.T, dir string) {
	for _, pattern := range filesToCleanup {
		matches, err := filepath.Glob(filepath.Join(dir, pattern))
		if err != nil {
			t.Logf("Error: %v", err)
			continue
		}
		for _, filePath := range matches {
			if err := os.RemoveAll(filePath); err != nil {
				t.Logf("Failed to remove %s: %v\n", filePath, err)
			} else {
				t.Logf("Successfully removed %s\n", filePath)
			}
		}
	}
}
