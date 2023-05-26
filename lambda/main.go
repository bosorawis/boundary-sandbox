package main

import (
	"context"
	"fmt"
	"os"
	"strings"

	"github.com/aws/aws-lambda-go/events"
	"github.com/aws/aws-lambda-go/lambda"
	"github.com/hashicorp/boundary/api"
	"github.com/hashicorp/boundary/api/authmethods"
	"github.com/hashicorp/boundary/api/workers"
)

func HandleRequest(ctx context.Context, event events.CloudwatchLogsEvent) (string, error) {
	parsed, err := event.AWSLogs.Parse()
	if err != nil {
		return "", fmt.Errorf("failed to parse CloudwatchLogsEvent: %w", err)
	}
	registEvents, err := convert(parsed)
	if err != nil {
		return "", fmt.Errorf("failed to convert input to events: %w", err)
	}
	err = register(ctx, registEvents)
	if err != nil {
		return "", fmt.Errorf("failed to register workers: %w", err)
	}
	return "SUCCEED", nil
}

type registrationEvent struct {
	taskID string
	token  string
}

func convert(e events.CloudwatchLogsData) ([]registrationEvent, error) {
	splitStream := strings.Split(e.LogStream, "/")
	if len(splitStream) != 3 {
		return []registrationEvent{}, fmt.Errorf("invalid logstream format. expects 2 '/' but got: %s", e.LogStream)
	}
	taskID := splitStream[2]
	result := []registrationEvent{}
	for _, event := range e.LogEvents {
		items := strings.Split(event.Message, ": ")
		if len(items) != 2 {
			continue
		}
		result = append(result, registrationEvent{
			taskID: taskID,
			token:  items[1],
		})
	}

	return result, nil
}

func register(ctx context.Context, events []registrationEvent) error {
	client, err := api.NewClient(nil)
	if err != nil {
		return fmt.Errorf("cannot instantiate boundary client: %w", err)
	}
	err = client.SetAddr(os.Getenv("CLUSTER_URL"))
	if err != nil {
		return fmt.Errorf("failed to set CLUSTER_URL to %s: %w", os.Getenv("CLUSTER_URL"), err)
	}
	credentials := map[string]interface{}{
		"login_name": os.Getenv("BOUNDARY_USERNAME"),
		"password":   os.Getenv("BOUNDARY_PASSWORD"),
	}
	amClient := authmethods.NewClient(client)
	authResult, err := amClient.Authenticate(ctx, os.Getenv("BOUNDARY_AUTH_MATHOD_ID"), "login", credentials)
	if err != nil {
		return fmt.Errorf("failed to authenticate: %w", err)
	}
	client.SetToken(fmt.Sprint(authResult.Attributes["token"]))

	workerClient := workers.NewClient(client)
	for _, e := range events {
		_, err := workerClient.CreateWorkerLed(ctx, e.token, "global")
		if err != nil {
			return fmt.Errorf("failed to register worker %s: %w", e.taskID, err)
		}
	}
	return nil
}

func main() {
	lambda.Start(HandleRequest)
}
