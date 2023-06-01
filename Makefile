
build:
	GOOS=linux GOARCH=amd64 go build -o ./bin/new-worker ./lambda/new-worker
