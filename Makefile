build: clean build-worker-auth-watcher build-worker_stop_watcher_zip

clean:
	rm -rf ./bin/

build-worker-auth-watcher:
	GOOS=linux GOARCH=amd64 go build -o ./bin/worker-auth-watcher ./lambda/worker-auth-watcher

build-worker_stop_watcher_zip:
	GOOS=linux GOARCH=amd64 go build -o ./bin/worker-stop-watcher ./lambda/worker-stop-watcher


docker:
	docker build --platform linux/amd64 -t boundary-worker .

docker-push: docker
	docker tag boundary-worker:latest 609442363224.dkr.ecr.us-west-2.amazonaws.com/boundary-worker:latest
	docker push 609442363224.dkr.ecr.us-west-2.amazonaws.com/boundary-worker:latest