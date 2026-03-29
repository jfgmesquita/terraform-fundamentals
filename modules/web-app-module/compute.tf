# EC2 INSTANCES (Using a Loop)
resource "aws_instance" "web_server" {
  count                  = var.instance_count
  ami                    = var.ami
  instance_type          = var.instance_type
  vpc_security_group_ids = [aws_security_group.instances.id]

  user_data = <<-EOF
              #!/bin/bash
              echo "Hello from Instance ${count.index + 1}" > index.html
              nohup python3 -m http.server ${var.server_port} &
              EOF

  tags = { Name = "web-server-${count.index}" }
}