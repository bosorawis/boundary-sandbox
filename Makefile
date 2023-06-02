build: clean build-worker-auth-watcher build-stopped-worker

clean:
	rm -rf ./bin/

build-worker-auth-watcher:
	GOOS=linux GOARCH=amd64 go build -o ./bin/worker-auth-watcher ./lambda/worker-auth-watcher

build-stopped-worker:
	GOOS=linux GOARCH=amd64 go build -o ./bin/stopped-worker ./lambda/stopped-worker
