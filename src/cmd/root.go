package cmd

import (
	"log"
	"os"

	"github.com/spf13/cobra"
)

// rootCmd represents the base command when called without any subcommands
var rootCmd = &cobra.Command{
	Use:   "build",
	Short: "Build deployment",
	Long: `Build deployment in folder using provided values, version, 
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
		name of deployment directory, default is 'deployment'

	--config
		name of config directory, default is 'config'
`,
	// Uncomment the following line if your bare application
	// has an action associated with it:
	Run: func(cmd *cobra.Command, args []string) { build() },
}

// Execute adds all child commands to the root command and sets flags appropriately.
// This is called by main.main(). It only needs to happen once to the rootCmd.
func Execute() {
	err := rootCmd.Execute()
	if err != nil {
		os.Exit(1)
	}
}

func init() {
	rootCmd.PersistentFlags().StringVar(&fileValues, "values", "values.yaml", "Yaml file with deployment values configuration")
	rootCmd.PersistentFlags().StringVar(&fileVersion, "version", "version.yaml", "Yaml file with deployment version configuration")
	rootCmd.PersistentFlags().StringVar(&fileImages, "images", "images.yaml", "Yaml file with deployment images configuration")
	rootCmd.PersistentFlags().StringVar(&fileBuild, "build", "build.json", "Json file with deployment build configuration")
	rootCmd.PersistentFlags().StringVar(&deploymentDir, "deployment", "deployment", "Json file with deployment build configuration")
	rootCmd.PersistentFlags().StringVar(&configDir, "config", "config", "Json file with deployment build configuration")
}

// build deployment files from templates in directory dir using provided name name
func buildComponent(dir string, name string) {
	//build deployment from directory with name
	//go through all files and build:
	tDir := dir + "/deploy"
	files, err := os.ReadDir(tDir)
	if err != nil {
		log.Fatal(err)
	}

	for _, file := range files {
		//skip directories
		if file.IsDir() {
			continue
		}

		/* moved init section into script
		if file.Name() == "_init.sh" {
			//need to make full template of all _init.sh files
			//and process it as template later
			copyFile(tDir+"/_init.sh", "./"+configDir+"/init.sh")
			continue
		}
		*/

		if file.Name() == "_prepare.sh" {
			//need to make full template of all _prepare.sh files
			//and process it as template later
			copyFile(tDir+"/_prepare.sh", "./"+configDir+"/prepare.sh")
			continue
		}

		if file.Name() == "_script.sh" {
			//_script.sh => scripts/<name>.sh
			// combine it with config/_script.sh template
			buildTemplate("scripts/"+name+".sh", "_script.sh", tDir+"/_script.sh", "./"+configDir+"/_script.sh")
			continue
		}

		//*.* => install/<name>/*.*
		os.Mkdir("./"+deploymentDir+"/install/"+name, os.ModePerm)
		buildTemplate("install/"+name+"/"+file.Name(), file.Name(), tDir+"/"+file.Name())
	}
}

// return location from name
func getLocation(loc string) string {
	switch loc {
	case "config":
		return configDir + "/"
	case "deployment":
		return deploymentDir + "/"
	default:
		return ""
	}
}

// processes build configuration
func processBuild(buildStruct []BuildStruct) {
	for _, val := range buildStruct {
		if len(val.Message) > 0 {
			write(val.Message + "...")
		}
		loc := getLocation(val.Location)
		locFrom := getLocation(val.From.Location)
		locTo := getLocation(val.To.Location)
		switch val.Type {
		case "copy":
			copyFile("./"+locFrom+val.From.Name, "./"+locTo+val.To.Name)
		case "move":
			copyFile("./"+locFrom+val.From.Name, "./"+locTo+val.To.Name)
			os.Remove("./" + locFrom + val.From.Name)
		case "template":
			buildTemplate(val.Name, val.From.Name, "./"+locFrom+val.From.Name)
		case "remove":
			os.Remove("./" + loc + val.Name)
		case "removeAll":
			os.RemoveAll("./" + loc + val.Name)
		case "mkDir":
			os.Mkdir("./"+loc+val.Name, os.ModePerm)
		}
	}
}

// build deployment
func build() {
	//clear previous log
	os.Mkdir("./"+deploymentDir, os.ModePerm)
	os.RemoveAll("./" + deploymentDir + "/log")
	os.Mkdir("./"+deploymentDir+"/log", os.ModePerm)
	write("Build started")

	//need to read config
	write("Reading configuration...")
	readValues(true)
	write("Deployment directory: " + deploymentDir)

	write("Clearing previous deployment...")
	//pre-build
	processBuild(buildConfig.Pre)

	write("Building deployment:")

	//build
	processBuild(buildConfig.Build)

	//build each component
	for _, val := range buildConfig.Components {
		write(val.Message + "...")
		buildComponent(val.Path, val.Name)
	}

	//post build
	processBuild(buildConfig.Post)

	write("Build finished")
}
