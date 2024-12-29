package testExamplesComplete

import (
	"context"
	"fmt"
	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/credentials"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/service/ec2"
	"github.com/gruntwork-io/terratest/modules/random"
	"github.com/gruntwork-io/terratest/modules/ssh"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/testcontainers/testcontainers-go"
	"github.com/testcontainers/testcontainers-go/wait"
	"os"
	"path/filepath"
	"strings"
	"testing"
	"time"

	testStructure "github.com/gruntwork-io/terratest/modules/test-structure"
	"github.com/stretchr/testify/assert"
)

// Constants for LocalStack and AWS
const (
	examplePath = "examples/complete"

	localstackImage = "localstack/localstack-pro:4.0.3"
	localstackPort  = "4566/tcp"

	localstackReadyLog = "Ready."
)

var awsProfile = getEnv("AWS_PROFILE", "localstack")
var awsRegion = getEnv("AWS_REGION", "us-east-1")
var envName = getEnv("ENV", "e2e-complete")
var useLocalStack = getEnv("USE_LOCALSTACK", "true") != "false" // Use LocalStack by default

// Ec2Keypair represents an EC2 key pair.
type Ec2Keypair struct {
	Name    string
	KeyPair ssh.KeyPair
}

// Test the Terraform module in examples/complete using Terratest.
func Test(t *testing.T) {
	ctx, cancel := context.WithTimeout(context.Background(), 15*time.Minute)
	defer cancel()

	rootFolder := "../"
	tempTestFolder := testStructure.CopyTerraformFolderToTemp(t, rootFolder, examplePath)

	var configPath, credentialsPath, endpoint string

	var ec2Client *ec2.EC2
	if useLocalStack {
		localstackAuthToken := getLocalStackAuthToken(t)
		localstackContainer := startLocalStack(ctx, t, localstackAuthToken)
		defer terminateContainer(ctx, localstackContainer)

		endpoint = getContainerEndpoint(ctx, t, localstackContainer)
		t.Logf("LocalStack endpoint: %s", endpoint)

		configPath, credentialsPath = setupAWSProfile(t, endpoint)
		t.Logf("AWS config: %s", configPath)
		ec2Client = createAWSClient(t, awsRegion, endpoint, credentialsPath, "localstack")
	} else {
		//home, err := os.UserHomeDir()
		//if err != nil {
		//	t.Fatal(err)
		//}
		//credentialsPath = path.Join(home, ".aws", "credentials")
		//configPath = path.Join(home, ".aws", "config")
		t.Logf("Using AWS profile %s", awsProfile)
		ec2Client = createAWSClient(t, awsRegion, "", credentialsPath, awsProfile)
	}

	keyPair := createEC2KeyPair(t, ec2Client)
	waitForKeyPairPresent(t, ec2Client, keyPair.Name)

	defer deleteEC2KeyPair(t, ec2Client, keyPair.Name)

	generateTerraformVariablesFile(t, envName, awsRegion, keyPair.Name, tempTestFolder)
	generateTerraformBackendFile(t, tempTestFolder)

	varFiles := []string{filepath.Join(tempTestFolder, "terraform.tfvars")}
	terraformOptions := &terraform.Options{
		TerraformDir: tempTestFolder,
		Upgrade:      true,
		VarFiles:     varFiles,
		EnvVars: map[string]string{
			"AWS_PROFILE":                 awsProfile,
			"AWS_REGION":                  awsRegion,
			"AWS_CONFIG_FILE":             configPath,
			"AWS_SHARED_CREDENTIALS_FILE": credentialsPath,
			"AWS_ENDPOINT_URL":            endpoint,
		},
	}

	defer cleanup(t, terraformOptions, tempTestFolder)

	terraform.InitAndApply(t, terraformOptions)

	vpcCidr := terraform.Output(t, terraformOptions, "vpc_cidr_block")
	assert.Equal(t, "10.1.0.0/16", vpcCidr)
}

func cleanup(t *testing.T, terraformOptions *terraform.Options, tempTestFolder string) {
	terraform.Destroy(t, terraformOptions)
	os.RemoveAll(tempTestFolder)
}

func generateTerraformVariablesFile(t *testing.T, envName string, awsRegion string, keyPairName string, tempTestFolder string) {
	tfVars := fmt.Sprintf(`
env               = "%s"
aws_region       = "%s"
ec2_key_pair_name = "%s"
namespace         = "nutcorp"
	`, envName, awsRegion, keyPairName)
	t.Logf("Writing terraform.tfvars file %s", tfVars)
	err := os.WriteFile(filepath.Join(tempTestFolder, "terraform.tfvars"), []byte(tfVars), 0644)
	if err != nil {
		t.Fatal(err)
	}
}

func generateTerraformBackendFile(t *testing.T, tempTestFolder string) {
	t.Logf("Generating backend.tf file")
	backend := `
provider "aws" {}

terraform {
  backend "local" {}
}`
	t.Logf("Writing backend.tf file %s", backend)
	err := os.WriteFile(filepath.Join(tempTestFolder, "backend.tf"), []byte(backend), 0644)
	if err != nil {
		t.Fatal(err)
	}
}

func importEC2KeyPair(ec2Client *ec2.EC2, keyPairName string, publicKey string) error {
	input := &ec2.ImportKeyPairInput{
		KeyName:           aws.String(keyPairName),
		PublicKeyMaterial: []byte(publicKey),
	}

	_, err := ec2Client.ImportKeyPair(input)
	return err
}

func createEC2KeyPair(t *testing.T, ec2Client *ec2.EC2) *Ec2Keypair {
	keyPairName := fmt.Sprintf("%s-%s", envName, strings.ToLower(random.UniqueId()))
	t.Logf("Creating EC2 key pair: %s", keyPairName)

	keyPair := ssh.GenerateRSAKeyPair(t, 2048)

	err := importEC2KeyPair(ec2Client, keyPairName, keyPair.PublicKey)
	if err != nil {
		t.Fatal(err)
	}

	return &Ec2Keypair{Name: keyPairName, KeyPair: *keyPair}

}

func deleteEC2KeyPair(t *testing.T, ec2Client *ec2.EC2, keyPairName string) {
	input := &ec2.DeleteKeyPairInput{
		KeyName: aws.String(keyPairName),
	}

	_, err := ec2Client.DeleteKeyPair(input)
	if err != nil {
		t.Fatalf("Failed to delete key pair %s: %v", keyPairName, err)
	}
	t.Logf("Deleted key pair %s", keyPairName)
}

func waitForKeyPairPresent(t *testing.T, ec2Client *ec2.EC2, keyPairName string) bool {
	for i := 0; i < 10; i++ {
		_, err := ec2Client.DescribeKeyPairs(&ec2.DescribeKeyPairsInput{
			KeyNames: []*string{aws.String(keyPairName)},
		})
		if err == nil {
			t.Logf("Key pair %s is now available", keyPairName)
			return true
		}
		t.Logf("Waiting for key pair %s to become available...", keyPairName)
		time.Sleep(1 * time.Second)
	}
	return false
}

func getLocalStackAuthToken(t *testing.T) string {
	token := os.Getenv("LOCALSTACK_AUTH_TOKEN")
	if token == "" {
		t.Fatalf("LOCALSTACK_AUTH_TOKEN is not set")
	}
	return token
}

func startLocalStack(ctx context.Context, t *testing.T, authToken string) testcontainers.Container {
	t.Logf("Starting LocalStack container")
	req := testcontainers.ContainerRequest{
		Image:        localstackImage,
		ExposedPorts: []string{localstackPort},
		Env: map[string]string{
			"LOCALSTACK_AUTH_TOKEN": authToken,
		},
		WaitingFor: wait.ForLog(localstackReadyLog),
	}

	cnt, err := testcontainers.GenericContainer(ctx, testcontainers.GenericContainerRequest{
		ContainerRequest: req,
		Started:          true,
	})
	if err != nil {
		t.Fatalf("Failed to start LocalStack container: %v", err)
	}
	t.Logf("LocalStack started")

	return cnt
}

func terminateContainer(ctx context.Context, container testcontainers.Container) {
	if err := container.Terminate(ctx); err != nil {
		fmt.Printf("Failed to terminate container: %v\n", err)
	}
}

func getContainerEndpoint(ctx context.Context, t *testing.T, container testcontainers.Container) string {
	endpoint, err := container.PortEndpoint(ctx, localstackPort, "http")
	if err != nil {
		t.Fatalf("Failed to get endpoint: %v", err)
	}
	return endpoint
}

func createAWSClient(t *testing.T, region, endpoint, credentialsPath, profile string) *ec2.EC2 {
	cfg := &aws.Config{
		Region:      aws.String(region),
		Endpoint:    aws.String(endpoint),
		Credentials: credentials.NewSharedCredentials(credentialsPath, profile),
	}

	sess, err := session.NewSession(cfg)
	if err != nil {
		t.Fatalf("Failed to create AWS session: %v", err)
	}

	return ec2.New(sess)
}

func setupAWSProfile(t *testing.T, endpoint string) (string, string) {
	tmpDir, _ := os.MkdirTemp("", "awsconfig")
	credentialsPath := filepath.Join(tmpDir, "credentials")
	configPath := filepath.Join(tmpDir, "config")

	_ = os.WriteFile(credentialsPath, []byte(`[localstack]
aws_access_key_id = test
aws_secret_access_key = test`), 0644)
	_ = os.WriteFile(configPath, []byte(fmt.Sprintf(`[profile localstack]
region = us-east-1
output = json
endpoint_url = %s
	`, endpoint)), 0644)

	return configPath, credentialsPath
}

func getEnv(key, fallback string) string {
	if value, exists := os.LookupEnv(key); exists {
		return value
	}
	return fallback
}
