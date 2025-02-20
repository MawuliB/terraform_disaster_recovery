resource "aws_instance" "web_server" {
  ami           = var.ami_id
  instance_type = var.instance_type
  subnet_id     = var.subnet_id
  vpc_security_group_ids = [ var.sg_id ]

  user_data = file("${path.root}/scripts/user_data.sh")

  tags = {
    Name = var.instance_name
  }
}

resource "time_sleep" "wait_for_instance" {
  depends_on = [aws_instance.web_server]
  create_duration = "60s"
}

resource "null_resource" "stop_instance" {
    depends_on = [ time_sleep.wait_for_instance ]
  triggers = {
    instance_id = aws_instance.web_server.id
  }

  provisioner "local-exec" {
    command = "aws ec2 stop-instances --instance-ids ${aws_instance.web_server.id} --region ${var.region}"
  }
  
}