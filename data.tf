locals  {
  vpc = data.aws_vpc.vpc.id
  subnets = data.aws_subnet.subnets.*.id
  sg = data.aws_security_group.sg.id
}
data "aws_vpc" "vpc" {
  default = true
}

data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_subnet" "subnets" {
  count = length(data.aws_availability_zones.available.zone_ids)
  vpc_id = data.aws_vpc.vpc.id
  availability_zone_id = data.aws_availability_zones.available.zone_ids[count.index]
}



data "aws_security_group" "sg" {
  vpc_id = local.vpc
  name = "default"
}

data "aws_iam_policy_document" "cron-worker" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}


data "aws_iam_policy_document" "events" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["events.amazonaws.com"]
    }
  }
}

data "template_file" "td" {
  template =  file("files/task.json")
  vars = {
    table_name = aws_dynamodb_table.cool_table.name
  }
}
