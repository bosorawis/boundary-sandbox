package main

import (
	"context"
	"fmt"

	"github.com/aws/aws-lambda-go/lambda"
)

func HandleRequest(ctx context.Context, data string) (string, error) {
	fmt.Println(data)
	return fmt.Sprintf(data), nil
}

func main() {
	lambda.Start(HandleRequest)
}
