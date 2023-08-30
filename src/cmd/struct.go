package cmd

// template map structure
type TemplateMap struct {
	Values     map[interface{}]interface{}
	Version    map[interface{}]interface{}
	Images     map[interface{}]interface{}
	Components []ComponentStruct
}

type ComponentStruct struct {
	Name    string `json:"name"`
	Path    string `json:"path"`
	Message string `json:"message"`
}

type BuildStruct struct {
	Message  string `json:"message"`
	Name     string `json:"name"`
	Location string `json:"location"`
	Type     string `json:"type"`
	From     struct {
		Location string `json:"location"`
		Name     string `json:"name"`
	} `json:"from"`
	To struct {
		Location string `json:"location"`
		Name     string `json:"name"`
	} `json:"to"`
}

// build.json structure
type BuildJson struct {
	Pre        []BuildStruct     `json:"pre"`
	Build      []BuildStruct     `json:"build"`
	Components []ComponentStruct `json:"components"`
	Post       []BuildStruct     `json:"post"`
}
