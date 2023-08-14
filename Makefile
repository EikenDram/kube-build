build:
	GOOS=linux GOARCH=amd64 go build build
	GOOS=windows GOARCH=amd64 go build build

run:
	go run build

run image:
	go run build image