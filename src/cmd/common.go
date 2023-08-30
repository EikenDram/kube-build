package cmd

import (
	"encoding/json"
	"io"
	"log"
	"os"
	"text/template"

	"github.com/Masterminds/sprig/v3"
	"gopkg.in/yaml.v3"
)

// template data
var templateData TemplateMap

// build configuration
var buildConfig BuildJson

// name of deployment directory
var deploymentDir string = "deployment"

// name of configuration directory
var configDir string = "config"

// version.yaml
var fileVersion string = "version.yaml"

// values.yaml
var fileValues string = "values.yaml"

// images.yaml
var fileImages string = "images.yaml"

// build.json
var fileBuild string = "build.json"

// write output to console and log file
func write(m string) {
	f, err := os.OpenFile("./"+deploymentDir+"/log/build.log", os.O_RDWR|os.O_CREATE|os.O_APPEND, 0666)
	check(err)
	defer f.Close()
	wrt := io.MultiWriter(os.Stdout, f)
	log.SetOutput(wrt)
	log.Println(m)
}

// read values from yaml file into variable
func readValues(log bool) {
	//read versions from version.yaml
	yamlVer, err := os.ReadFile("./" + configDir + "/" + fileVersion)
	check(err)
	var ver = make(map[interface{}]interface{})
	err = yaml.Unmarshal([]byte(yamlVer), &ver)
	check(err)
	if log {
		write("Version configuration loaded from: " + fileVersion)
		_ = os.WriteFile("./"+deploymentDir+"/log/version.yaml", yamlVer, 0644)
	}

	//read configuration from values.yaml
	yamlVal, err := os.ReadFile("./" + configDir + "/" + fileValues)
	check(err)
	var val = make(map[interface{}]interface{})
	err = yaml.Unmarshal([]byte(yamlVal), &val)
	check(err)
	if log {
		write("Values configuration loaded from: " + fileVersion)
		_ = os.WriteFile("./"+deploymentDir+"/log/values.yaml", yamlVal, 0644)
	}

	//read images from images.yaml
	yamlImg, err := os.ReadFile("./" + configDir + "/" + fileImages)
	check(err)
	var img = make(map[interface{}]interface{})
	err = yaml.Unmarshal([]byte(yamlImg), &img)
	check(err)
	if log {
		write("Images configuration loaded from: " + fileImages)
		_ = os.WriteFile("./"+deploymentDir+"/log/images.yaml", yamlImg, 0644)
	}

	//read build configuration from build.json
	file, err := os.ReadFile("./" + configDir + "/" + fileBuild)
	check(err)
	if err := json.Unmarshal(file, &buildConfig); err != nil {
		panic(err)
	}
	if log {
		write("Build configuration loaded from: " + fileBuild)
		_ = os.WriteFile("./"+deploymentDir+"/log/build.json", file, 0644)
	}

	//create map
	templateData = TemplateMap{val, ver, img, buildConfig.Components}
}

// copy file
func copyFile(fileIn string, fileOut string) {
	fIn, err := os.Open(fileIn)
	check(err)
	defer fIn.Close()

	fOut, err := os.OpenFile(fileOut, os.O_APPEND|os.O_CREATE|os.O_WRONLY, 0644)
	check(err)
	defer fOut.Close()

	_, err = io.Copy(fOut, fIn)
	check(err)
}

// executes template tmpl from filenames to file fout using loaded values
func buildTemplate(fileOut string, templateName string, filenames ...string) {
	fileOut = "./" + deploymentDir + "/" + fileOut

	t, err := template.New("").
		Option("missingkey=zero").
		Funcs(sprig.TxtFuncMap()).
		ParseFiles(filenames...)
	check(err)

	f, err := os.OpenFile(fileOut, os.O_APPEND|os.O_WRONLY|os.O_CREATE, 0600)
	check(err)

	err = t.ExecuteTemplate(f, templateName, templateData)
	check(err)
}

func check(err error) {
	if err != nil {
		panic(err)
	}
}
