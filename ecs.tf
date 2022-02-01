#---------------------------------------------------
# Create ESC Cluster
#---------------------------------------------------
resource "aws_ecs_cluster" "main" {
  name = "${var.project}-${var.env}"
}

#---------------------------------------------------
# Create ESC Task definition for Cluster
#---------------------------------------------------

resource "aws_ecs_task_definition" "web_server" {
  family                   = "${var.project}-${var.env}-${var.name_container}"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.websrv_fargate_cpu
  memory                   = var.websrv_fargate_memory
  container_definitions = jsonencode(
    [
      {
        name        = "nginx"
        image       = aws_ecr_repository.repository.repository_url
        cpu         = var.websrv_fargate_cpu
        memory      = var.websrv_fargate_memory
        networkMode = "awsvpc"

        portMappings = [{
          containerPort = var.app_port
          hostPort      = var.app_port
        }]
      }
    ]
  )
}
#---------------------------------------------------
# Create ESC  task security group
#---------------------------------------------------
resource "aws_security_group" "web_server_task" {
  name   = "${var.project}_${var.env}_sg_web_server_task"
  vpc_id = aws_vpc.newvpc.id

  ingress {
    protocol    = "tcp"
    from_port   = var.app_port
    to_port     = var.app_port
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}
#---------------------------------------------------
# Create ESC  service
#---------------------------------------------------
#ESC service
resource "aws_ecs_service" "web_server" {
  name            = "${var.project}-${var.env}-${var.name_container}"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.web_server.arn
  desired_count   = var.web_server_count
  launch_type     = "FARGATE"

  network_configuration {
    security_groups  = [aws_security_group.web_server_task.id]
    subnets          = aws_subnet.privsubnets.*.id
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_alb_target_group.mytarget.id
    container_name   = var.name_container
    container_port   = var.app_port
  }

  depends_on = [aws_ecs_cluster.main, aws_alb_listener.http, aws_iam_role_policy_attachment.ecs_task_execution_role, aws_security_group.web_server_task]
}
