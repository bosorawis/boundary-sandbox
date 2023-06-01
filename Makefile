build: clean build-new-worker build-stopped-worker

clean:
	rm -rf ./bin/

build-new-worker:
	GOOS=linux GOARCH=amd64 go build -o ./bin/new-worker ./lambda/new-worker

build-stopped-worker:
	GOOS=linux GOARCH=amd64 go build -o ./bin/stopped-worker ./lambda/stopped-worker
