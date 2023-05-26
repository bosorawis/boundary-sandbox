resource "aws_ecr_repository" "main" {
  name                 = "boundary-worker"
  image_tag_mutability = "MUTABLE"
}

resource "aws_ecr_lifecycle_policy" "main" {
  repository = aws_ecr_repository.main.name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "keep last 10 images"
        action       = {
          type = "expire"
        }
        selection = {
          tagStatus   = "any"
          countType   = "imageCountMoreThan"
          countNumber = 10
        }
      }
    ]
  })
}

resource "aws_ecs_cluster" "boundary-worker-clusters" {
  name = "boundary-workers-cluster"
}


resource "aws_ecs_task_definition" "main" {
  network_mode             = "awsvpc"
  family                   = "service"
  requires_compatibilities = ["FARGATE"]
  cpu                      = 256
  memory                   = 512
  container_definitions    = jsonencode([
    {
      name         = "boundary-worker"
      image        = "${aws_ecr_repository.main.repository_url}:latest"
      essential    = true
    }
  ])
}

