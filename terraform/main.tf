provider "aws" {
  region = "us-east-1"
}

terraform {
  required_version = ">= 0.11.7"

  backend "s3" {
    bucket = "andres-snaptravel-tfstate"
    key    = "andres-snaptravel-tfstate"
    region = "us-east-1"
  }
}

data "aws_availability_zones" "zones" {}

resource "aws_vpc" "vpc" {
  tags {
    Name = "Andres-Snaptravel"
  }

  cidr_block           = "${var.vpc_cidr_block}"
  enable_dns_hostnames = true
  enable_dns_support   = true
  instance_tenancy     = "default"
}

resource "aws_vpc_dhcp_options" "dhcp_options" {
  domain_name         = "${var.aws_region}.compute.internal"
  domain_name_servers = ["AmazonProvidedDNS"]
}

resource "aws_vpc_dhcp_options_association" "dhcp_assoc" {
  vpc_id          = "${aws_vpc.vpc.id}"
  dhcp_options_id = "${aws_vpc_dhcp_options.dhcp_options.id}"
}

resource "aws_subnet" "public" {
  count             = "${length(var.public_cidr_blocks)}"
  vpc_id            = "${aws_vpc.vpc.id}"
  availability_zone = "${element(data.aws_availability_zones.zones.names, count.index)}"
  cidr_block        = "${element(var.public_cidr_blocks, count.index)}"

  tags {
    Type = "public"
  }
}

resource "aws_subnet" "private" {
  count             = "${length(var.private_cidr_blocks)}"
  vpc_id            = "${aws_vpc.vpc.id}"
  availability_zone = "${element(data.aws_availability_zones.zones.names, count.index)}"
  cidr_block        = "${element(var.private_cidr_blocks, count.index)}"

  tags {
    Type = "private"
  }
}

resource "aws_eip" "ngw" {
  count = "${length(data.aws_availability_zones.zones.names)}"
  vpc   = true
}

resource "aws_internet_gateway" "igw" {
  vpc_id = "${aws_vpc.vpc.id}"
}

resource "aws_nat_gateway" "ngw" {
  count         = "${length(data.aws_availability_zones.zones.names)}"
  subnet_id     = "${element(aws_subnet.public.*.id, count.index)}"
  allocation_id = "${element(aws_eip.ngw.*.id, count.index)}"
  depends_on    = ["aws_internet_gateway.igw"]
}

resource "aws_route_table" "rtb_igw" {
  vpc_id = "${aws_vpc.vpc.id}"
}

resource "aws_route" "to_igw" {
  route_table_id         = "${aws_route_table.rtb_igw.id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.igw.id}"
}

resource "aws_main_route_table_association" "main-rtb" {
  vpc_id         = "${aws_vpc.vpc.id}"
  route_table_id = "${aws_route_table.rtb_igw.id}"
}

resource "aws_route_table" "rtb_ngw" {
  count  = "${length(data.aws_availability_zones.zones.names)}"
  vpc_id = "${aws_vpc.vpc.id}"
}

resource "aws_route" "to_ngw" {
  count                  = "${length(data.aws_availability_zones.zones.names)}"
  route_table_id         = "${element(aws_route_table.rtb_ngw.*.id, count.index)}"
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = "${element(aws_nat_gateway.ngw.*.id, count.index)}"
}

resource "aws_route_table_association" "rtb_assoc_ngw" {
  count          = "${length(var.private_cidr_blocks)}"
  subnet_id      = "${element(aws_subnet.private.*.id, count.index)}"
  route_table_id = "${element(aws_route_table.rtb_ngw.*.id, count.index)}"
  depends_on     = ["aws_subnet.private"]
}

resource "aws_cloudwatch_log_group" "flask_backend" {
  name = "flask_backend"

  tags {
    Application = "flask_backend"
  }
}

resource "aws_security_group" "elasticache_sg" {
  name        = "elasticache_redis_security_group"
  description = "Allow redis traffic from within VPC"
  vpc_id      = "${aws_vpc.vpc.id}"

  ingress {
    from_port   = 6379
    to_port     = 6379
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "elasticache_redis_security_group"
  }
}

resource "aws_elasticache_subnet_group" "redis_private" {
  name       = "private-ec-redis-subnet-groups"
  subnet_ids = ["${data.aws_subnet_ids.private.ids}"]
}

resource "aws_elasticache_replication_group" "redis" {
  automatic_failover_enabled    = true
  availability_zones            = ["us-east-1a", "us-east-1b"]
  replication_group_id          = "primary-redis"
  replication_group_description = "Main redis replication group"
  node_type                     = "cache.r4.large"
  number_cache_clusters         = 2
  parameter_group_name          = "default.redis4.0"
  port                          = 6379
  subnet_group_name             = "${aws_elasticache_subnet_group.redis_private.name}"
  security_group_ids            = ["${aws_security_group.elasticache_sg.id}"]
}

resource "aws_ecr_repository" "snaptravel-andres" {
  name = "snaptravel-andres"
}

resource "aws_ecs_cluster" "snaptravel-andres" {
  name = "snaptravel-andres"
}

data "aws_iam_policy_document" "ecs_service_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ecs_role" {
  name               = "ecs_role"
  assume_role_policy = "${data.aws_iam_policy_document.ecs_service_role.json}"
}

data "aws_iam_policy_document" "ecs_service_policy" {
  statement {
    effect    = "Allow"
    resources = ["*"]

    actions = [
      "elasticloadbalancing:Describe*",
      "elasticloadbalancing:DeregisterInstancesFromLoadBalancer",
      "elasticloadbalancing:RegisterInstancesWithLoadBalancer",
      "ec2:Describe*",
      "ec2:AuthorizeSecurityGroupIngress",
    ]
  }
}

/* ecs service scheduler role */
resource "aws_iam_role_policy" "ecs_service_role_policy" {
  name = "ecs_service_role_policy"

  #policy = "${file("${path.module}/policies/ecs-service-role.json")}"
  policy = "${data.aws_iam_policy_document.ecs_service_policy.json}"
  role   = "${aws_iam_role.ecs_role.id}"
}

/* role that the Amazon ECS container agent and the Docker daemon can assume */
resource "aws_iam_role" "ecs_execution_role" {
  name               = "ecs_task_execution_role"
  assume_role_policy = "${file("${path.module}/policies/ecs-task-execution-role.json")}"
}

resource "aws_iam_role_policy" "ecs_execution_role_policy" {
  name   = "ecs_execution_role_policy"
  policy = "${file("${path.module}/policies/ecs-execution-role-policy.json")}"
  role   = "${aws_iam_role.ecs_execution_role.id}"
}

data "template_file" "flask_backend_task" {
  template = "${file("${path.module}/tasks/backend_definition.json")}"

  vars {
    image      = "${aws_ecr_repository.snaptravel-andres.repository_url}"
    secret_key = "${var.secret_key}"
    redis_url  = "${aws_elasticache_replication_group.redis.primary_endpoint_address}"
  }
}

resource "aws_ecs_task_definition" "flask_backend" {
  family                   = "backend"
  container_definitions    = "${data.template_file.flask_backend_task.rendered}"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "2048"
  memory                   = "4096"
  execution_role_arn       = "${aws_iam_role.ecs_execution_role.arn}"
  task_role_arn            = "${aws_iam_role.ecs_execution_role.arn}"
}

resource "random_id" "target_group_suffix" {
  byte_length = 4
}

resource "aws_alb_target_group" "alb_target_group" {
  name        = "alb-target-group-${random_id.target_group_suffix.hex}"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = "${aws_vpc.vpc.id}"
  target_type = "ip"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group" "flask_backend_inbound_sg" {
  name        = "backend-flask_backend-inbound-sg"
  description = "Allow HTTP from Anywhere into ALB"
  vpc_id      = "${aws_vpc.vpc.id}"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "backend-flask_backend-inbound-sg"
  }
}

data "aws_subnet_ids" "public" {
  vpc_id = "${aws_vpc.vpc.id}"

  tags {
    Type = "public"
  }

  depends_on = ["aws_subnet.public"]
}

data "aws_subnet_ids" "private" {
  vpc_id = "${aws_vpc.vpc.id}"

  tags {
    Type = "private"
  }

  depends_on = ["aws_subnet.private"]
}

resource "aws_alb" "alb_backend" {
  name            = "backend-alb"
  subnets         = ["${data.aws_subnet_ids.public.ids}"]
  security_groups = ["${aws_security_group.flask_backend_inbound_sg.id}"]

  tags {
    Name        = "backend-alb"
    Environment = "backend"
  }
}

resource "aws_alb_listener" "backend" {
  load_balancer_arn = "${aws_alb.alb_backend.arn}"
  port              = "80"
  protocol          = "HTTP"
  depends_on        = ["aws_alb_target_group.alb_target_group"]

  default_action {
    target_group_arn = "${aws_alb_target_group.alb_target_group.arn}"
    type             = "forward"
  }
}

resource "aws_security_group" "ecs_service" {
  vpc_id      = "${aws_vpc.vpc.id}"
  name        = "backend-ecs-service-sg"
  description = "Allow egress from container"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "backend-ecs-service-sg"
  }
}

/* Simply specify the family to find the latest ACTIVE revision in that family */
data "aws_ecs_task_definition" "flask_backend" {
  task_definition = "${aws_ecs_task_definition.flask_backend.family}"
  depends_on      = ["aws_ecs_task_definition.flask_backend"]
}

resource "aws_ecs_service" "flask_backend" {
  name            = "snaptravel-andres"
  task_definition = "${aws_ecs_task_definition.flask_backend.family}:${max("${aws_ecs_task_definition.flask_backend.revision}", "${data.aws_ecs_task_definition.flask_backend.revision}")}"
  desired_count   = 2
  launch_type     = "FARGATE"
  cluster         = "${aws_ecs_cluster.snaptravel-andres.id}"
  depends_on      = ["aws_iam_role_policy.ecs_service_role_policy"]

  network_configuration {
    security_groups  = ["${aws_security_group.flask_backend_inbound_sg.id}", "${aws_security_group.ecs_service.id}"]
    subnets          = ["${data.aws_subnet_ids.public.ids}"]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = "${aws_alb_target_group.alb_target_group.arn}"
    container_name   = "flask_backend"
    container_port   = "80"
  }

  deployment_maximum_percent = 400

  depends_on = ["aws_alb_target_group.alb_target_group"]
}

# Autoscaling
resource "aws_iam_role" "ecs_autoscale_role" {
  name               = "${var.environment}_ecs_autoscale_role"
  assume_role_policy = "${file("${path.module}/policies/ecs-autoscale-role.json")}"
}

resource "aws_iam_role_policy" "ecs_autoscale_role_policy" {
  name   = "ecs_autoscale_role_policy"
  policy = "${file("${path.module}/policies/ecs-autoscale-role-policy.json")}"
  role   = "${aws_iam_role.ecs_autoscale_role.id}"
}

resource "aws_appautoscaling_target" "target" {
  service_namespace  = "ecs"
  resource_id        = "service/${aws_ecs_cluster.snaptravel-andres.name}/${aws_ecs_service.flask_backend.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  role_arn           = "${aws_iam_role.ecs_autoscale_role.arn}"
  min_capacity       = 1
  max_capacity       = 8
}

resource "aws_appautoscaling_policy" "up" {
  name               = "backend_scale_up"
  service_namespace  = "ecs"
  resource_id        = "service/${aws_ecs_cluster.snaptravel-andres.name}/${aws_ecs_service.flask_backend.name}"
  scalable_dimension = "ecs:service:DesiredCount"

  step_scaling_policy_configuration {
    adjustment_type         = "ChangeInCapacity"
    cooldown                = 60
    metric_aggregation_type = "Maximum"

    step_adjustment {
      metric_interval_lower_bound = 0
      scaling_adjustment          = 1
    }
  }

  depends_on = ["aws_appautoscaling_target.target"]
}

resource "aws_appautoscaling_policy" "down" {
  name               = "${var.environment}_scale_down"
  service_namespace  = "ecs"
  resource_id        = "service/${aws_ecs_cluster.snaptravel-andres.name}/${aws_ecs_service.flask_backend.name}"
  scalable_dimension = "ecs:service:DesiredCount"

  step_scaling_policy_configuration {
    adjustment_type         = "ChangeInCapacity"
    cooldown                = 60
    metric_aggregation_type = "Maximum"

    step_adjustment {
      metric_interval_lower_bound = 0
      scaling_adjustment          = -1
    }
  }

  depends_on = ["aws_appautoscaling_target.target"]
}

/* metric used for auto scale */
resource "aws_cloudwatch_metric_alarm" "service_cpu_high" {
  alarm_name          = "${var.environment}_backend_flask_backend_cpu_utilization_high"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = "60"
  statistic           = "Maximum"
  threshold           = "85"

  dimensions {
    ClusterName = "${aws_ecs_cluster.snaptravel-andres.name}"
    ServiceName = "${aws_ecs_service.flask_backend.name}"
  }

  alarm_actions = ["${aws_appautoscaling_policy.up.arn}"]
  ok_actions    = ["${aws_appautoscaling_policy.down.arn}"]
}

# code pipeline
resource "aws_s3_bucket" "source" {
  bucket        = "snaptravel-andres-s3-source"
  acl           = "private"
  force_destroy = true
}

resource "aws_iam_role" "codepipeline_role" {
  name = "codepipeline-role"

  assume_role_policy = "${file("${path.module}/policies/codepipeline_role.json")}"
}

/* policies */
data "template_file" "codepipeline_policy" {
  template = "${file("${path.module}/policies/codepipeline.json")}"

  vars {
    aws_s3_bucket_arn = "${aws_s3_bucket.source.arn}"
  }
}

resource "aws_iam_role_policy" "codepipeline_policy" {
  name   = "codepipeline_policy"
  role   = "${aws_iam_role.codepipeline_role.id}"
  policy = "${data.template_file.codepipeline_policy.rendered}"
}

/*
/* CodeBuild
*/
resource "aws_iam_role" "codebuild_role" {
  name               = "codebuild-role"
  assume_role_policy = "${file("${path.module}/policies/codebuild_role.json")}"
}

data "template_file" "codebuild_policy" {
  template = "${file("${path.module}/policies/codebuild_policy.json")}"

  vars {
    aws_s3_bucket_arn = "${aws_s3_bucket.source.arn}"
  }
}

resource "aws_iam_role_policy" "codebuild_policy" {
  name   = "codebuild-policy"
  role   = "${aws_iam_role.codebuild_role.id}"
  policy = "${data.template_file.codebuild_policy.rendered}"
}

data "template_file" "buildspec" {
  template = "${file("${path.module}/buildspec.yml")}"

  vars {
    repository_url = "${aws_ecr_repository.snaptravel-andres.repository_url}"
    region         = "${var.aws_region}"
  }
}

resource "aws_codebuild_project" "backend_build" {
  name          = "infrastructure-demo-codebuild-project"
  build_timeout = "10"
  service_role  = "${aws_iam_role.codebuild_role.arn}"

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type = "BUILD_GENERAL1_SMALL"

    // https://docs.aws.amazon.com/codebuild/latest/userguide/build-env-ref-available.html
    image           = "aws/codebuild/python:3.6.5"
    type            = "LINUX_CONTAINER"
    privileged_mode = true
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = "${data.template_file.buildspec.rendered}"
  }
}

/* CodePipeline */

resource "aws_codepipeline" "pipeline" {
  name     = "flask_backend-pipeline"
  role_arn = "${aws_iam_role.codepipeline_role.arn}"

  artifact_store {
    location = "${aws_s3_bucket.source.bucket}"
    type     = "S3"
  }

  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "ThirdParty"
      provider         = "GitHub"
      version          = "1"
      output_artifacts = ["source"]

      configuration {
        Owner  = "andres-de-castro"
        Repo   = "infrastructure-demo"
        Branch = "master"
      }
    }
  }

  stage {
    name = "Build"

    action {
      name             = "Build"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      version          = "1"
      input_artifacts  = ["source"]
      output_artifacts = ["imagedefinitions"]

      configuration {
        ProjectName = "${aws_codebuild_project.backend_build.name}"
      }
    }
  }

  stage {
    name = "Production"

    action {
      name            = "Deploy"
      category        = "Deploy"
      owner           = "AWS"
      provider        = "ECS"
      input_artifacts = ["imagedefinitions"]
      version         = "1"

      configuration {
        ClusterName = "${aws_ecs_cluster.snaptravel-andres.id}"
        ServiceName = "snaptravel-andres"
        FileName    = "imagedefinitions.json"
      }
    }
  }
}
