FROM alpine AS builder

WORKDIR /boundary

RUN apk update && \
    apk add curl unzip

RUN curl -o boundary-worker.zip https://releases.hashicorp.com/boundary-worker/0.12.2+hcp/boundary-worker_0.12.2+hcp_linux_amd64.zip && \
    unzip boundary-worker.zip && \
    chmod +x boundary-worker


FROM alpine

EXPOSE 9200
WORKDIR /boundary

COPY worker.hcl worker.hcl
COPY --from=builder /boundary/boundary-worker boundary-worker

CMD ["./boundary-worker", "server", "-config=./worker.hcl"]