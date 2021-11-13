resource "aws_cloudwatch_event_rule" "cron" {
  name                = "cron"
  description         = "cron"
  schedule_expression = "cron(* * * * ? *)"
}

resource "aws_cloudwatch_event_target" "ecs_scheduled_task" {
  arn      = aws_ecs_cluster.cluster.arn
  rule     = aws_cloudwatch_event_rule.cron.id
  role_arn = aws_iam_role.events.arn

  ecs_target {
    task_count          = 1
    task_definition_arn = trimsuffix(aws_ecs_task_definition.td.arn, ":${aws_ecs_task_definition.td.revision}")
    launch_type         = "FARGATE"
    network_configuration {
      assign_public_ip = true
      security_groups  = [local.sg]
      subnets          = local.subnets
    }
  }
}