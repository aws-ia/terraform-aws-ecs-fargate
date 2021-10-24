package test

import (
	"fmt"
	"net/http"
	"testing"
	"time"

	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

func TestEcsDeploy(t *testing.T) {
	t.Parallel()

	terraformOptions := &terraform.Options{
		TerraformDir: "../deploy",
		Vars: map[string]interface{}{
			"region": "eu-west-1"},
	}

	//defer terraform.Destroy(t, terraformOptions)
	terraform.InitAndApply(t, terraformOptions)

	dns, _ := terraform.OutputE(t, terraformOptions, "public_lb_dns_name")

	var response *http.Response
	var err error
	// Sleep and retry if request fails since ECS might need time to start.
	for i := 0; i < 3; i++ {
		response, err = http.Get(fmt.Sprintf("http://%s", dns))
		if err != nil {
			time.Sleep(10 * time.Second)
		} else {
			break
		}
	}

	require.NoError(t, err, "request returned an unexpected error")
	assert.Equal(t, http.StatusOK, response.StatusCode)
}
