/*provider "aws" {
  region     = "us-east-1"
  access_key = ""
  secret_key = ""
}*/
resource "aws_dynamodb_table" "cool_table" {
  name           = "cool"
  billing_mode   = "PROVISIONED"
  read_capacity  = 1
  write_capacity = 1
  hash_key       = "Id"

  attribute {
    name = "Id"
    type = "N"
  }
}

resource "aws_ecs_cluster" "cluster" {
  name = "cool-cluster"

}

resource "aws_iam_role" "cron_worker" {
  name               = "cron-worker"
  assume_role_policy = data.aws_iam_policy_document.cron-worker.json
}

resource "aws_iam_policy" "cron_worker_policy" {
  name   = "cron-worker"
  path   = "/"
  policy = file("files/cron-worker.json")
}

resource "aws_iam_role_policy_attachment" "cron_worker_role_attach_policy" {
  role       = aws_iam_role.cron_worker.name
  policy_arn = aws_iam_policy.cron_worker_policy.arn
}

resource "aws_iam_role" "events" {
  name               = "events"
  assume_role_policy = data.aws_iam_policy_document.events.json
}

resource "aws_iam_policy" "cron_events_policy" {
  name   = "events"
  path   = "/"
  policy = file("files/events_policy.json")
}

resource "aws_iam_role_policy_attachment" "cron_events_role_attach_policy" {
  role       = aws_iam_role.events.name
  policy_arn = aws_iam_policy.cron_events_policy.arn
}

resource "aws_cloudwatch_log_group" "log_g_cron" {
  name              = "/ecs/cron-worker"
  retention_in_days = 14

}

resource "aws_ecs_task_definition" "td" {
  family                   = "cron-worker"
  container_definitions    = data.template_file.td.rendered
  task_role_arn            = aws_iam_role.cron_worker.arn
  execution_role_arn       = aws_iam_role.cron_worker.arn
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  memory                   = "512"
  cpu                      = "256"
}