# Data Source for getting Amazon Linux AMI
data "aws_ami" "amazon-2" {
  most_recent = true

  filter {
    name = "name"
    values = ["amzn2-ami-hvm-*-x86_64-ebs"]
  }
  owners = ["amazon"]
}

########################################################### vm_datadog 9 Stück. 
resource "aws_instance" "vm_datadog" {
  ami = data.aws_ami.amazon-2.id
  instance_type = "t3.micro"
  count = 9

  user_data = templatefile("${path.module}/templates/init_main.tpl", { 
    VarDdApiKey = var.VarDdApiKey,
    VarDdImage = "gcr.io/datadoghq/agent:7" 
  } )

  vpc_security_group_ids = [aws_security_group.ingress-all-ssh.id, aws_security_group.ingress-all-udp.id]

  tags = {
    Name = "vm_datadog.${count.index}"  
  }

#  Deaktiviert, weil AWS Student keine Power hat
#  lifecycle {
#    create_before_destroy = true
#  }
}

########################################################### Security ###########################################################


resource "aws_security_group" "ingress-all-ssh" {
  name = "allow-all-ssh"
  ingress {
    cidr_blocks = [
      "0.0.0.0/0"
    ]
    from_port = 22
    to_port = 22
    protocol = "tcp"
  }
  // Terraform removes the default rule
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "ingress-all-udp" {
  name = "allow-all-udp"
  ingress {
    cidr_blocks = [
      "0.0.0.0/0"
    ]
    from_port = 8125
    to_port = 8125
    protocol = "udp"
  }
  // Terraform removes the default rule
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

