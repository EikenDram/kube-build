package cmd

import (
	"fmt"
	"os"
	"os/exec"

	"github.com/spf13/cobra"
)

// don't replace configuration images.yaml
var dryRun bool = false

// imageCmd represents the image command
var imageCmd = &cobra.Command{
	Use:   "images",
	Short: "Build script for updating images.yaml",
	Long: `Build script for updating images configuration from 
manifests and helm charts using provided values, version, 
images and build configuration.
	
Change default configuration with flags:

	--values
		yaml file with configuration values, 
		default is values.yaml in config directory

	--version
		yaml file with version configuration, 
		default is version.yaml in config directory

	--images
		yaml file with docker images configuration,
	    default is images.yaml in config directory

	--build
		json file with build configuration,
	    default is build.json in config directory

	--deployment
		name of deployment directory,
		default is 'deployment'

	--config
		name of config directory,
		default is 'config'`,
	Run: func(cmd *cobra.Command, args []string) {
		images()
	},
}

func init() {
	rootCmd.AddCommand(imageCmd)
	imageCmd.Flags().BoolVar(&dryRun, "dry-run", false, "Don't overwrite configuration file")
}

// run images.sh script
func shImages() string {
	cmd, err := exec.Command("/bin/bash", "./"+deploymentDir+"/images.sh", deploymentDir).Output()
	check(err)

	output := string(cmd)
	return output
}

// update images.yaml from all manifests and helm charts
func images() {
	//create script to get images list from deployment
	fmt.Println("Generating " + deploymentDir + "/images.sh script...")
	readValues(false)
	os.Remove("./" + deploymentDir + "/images.sh")
	buildTemplate("images.sh", "_images.sh", "./"+configDir+"/_images.sh")

	//run the script
	fmt.Println("Running images.sh script...")
	fmt.Println("Should be installed:")
	fmt.Println("    helm images plugin")
	fmt.Println("    yq")

	cmd := shImages()
	fmt.Print(cmd)

	//if not dry-run, replace images.yaml in configuration
	if !dryRun {
		fmt.Println("Updating configuration " + configDir + "/" + fileImages + "...")
		os.Remove("./" + configDir + "/" + fileImages)
		copyFile("./"+deploymentDir+"/images.yaml", "./"+configDir+"/"+fileImages)
	}

	fmt.Println("Done.")
}
