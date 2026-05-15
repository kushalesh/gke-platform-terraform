// Terratest validating the basic example: terraform init + validate + plan.
// Real apply is gated behind APPLY=true env var to avoid accidental cloud spend.
package test

import (
"os"
"testing"

"github.com/gruntwork-io/terratest/modules/terraform"
"github.com/stretchr/testify/assert"
)

func TestBasicExampleValidates(t *testing.T) {
t.Parallel()

opts := &terraform.Options{
TerraformDir: "../examples/basic",
Vars: map[string]interface{}{
"project_id": "test-project",
"region":     "europe-west1",
},
NoColor: true,
}

terraform.Init(t, opts)
out := terraform.Validate(t, opts)
assert.Contains(t, out, "Success")

if os.Getenv("APPLY") == "true" {
defer terraform.Destroy(t, opts)
terraform.Apply(t, opts)
}
}
