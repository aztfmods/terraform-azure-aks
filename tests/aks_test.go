package main

import (
	"os"
	"testing"

	"github.com/aztfmods/module-azurerm-aks/shared"
	"github.com/gruntwork-io/terratest/modules/terraform"
)

func TestAppyNoError(t *testing.T) {
	t.Parallel()

	tests := []shared.TestCase{
		{Name: os.Getenv("USECASE"), Path: "../examples/" + os.Getenv("USECASE")},
	}

	for _, test := range tests {
		t.Run(test.Name, func(t *testing.T) {
			terraformOptions := shared.GetTerraformOptions(test.Path)

			terraform.WithDefaultRetryableErrors(t, &terraform.Options{})

			defer shared.Cleanup(t, terraformOptions)
			terraform.InitAndApply(t, terraformOptions)
		})
	}
}
