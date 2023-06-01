package main

import (
	"context"
	"fmt"

	"github.com/aws/aws-lambda-go/lambda"
)

func HandleRequest(ctx context.Context, event any) (string, error) {
	fmt.Println(event)
	return "SUCCEED", nil
}

func main() {
	lambda.Start(HandleRequest)
}
