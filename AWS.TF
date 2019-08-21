provider "aws" {
  access_key = ""
  secret_key = ""
  region     = "us-east-1"
}
#------------------------------------------------------------------------------
#-------------------EXTERNAL SECURITY GROUP RDP------------------------------------
#------------------------------------------------------------------------------
resource "aws_security_group" "allow_RDP" {
  name        = "allow_RDP"
  description = "Allow RDP inbound traffic"
  vpc_id      = "vpc-f64ac68c"
  ingress {
    # TLS (change to whatever ports you need)
    from_port   = 3389
    to_port     = 3389
    protocol    = "tcp"
    # Please restrict your ingress to only necessary IPs and ports.
    # Opening to 0.0.0.0/0 can lead to security vulnerabilities.
    cidr_blocks = "${split(",", "69.60.82.0/24,69.60.84.0/24,66.229.125.0/24,50.203.241.19/32")}"
      }
  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
    #prefix_list_ids = ["pl-12c4e678"]
  }
}
#------------------------------------------------------------------------------
#------------------------------------------------------------------------------
#-------------------EXTERNAL SECURITY GROUP SSH------------------------------------
#------------------------------------------------------------------------------
resource "aws_security_group" "allow_SSH" {
  name        = "allow_SSH"
  description = "Allow SSH inbound traffic"
  vpc_id      = "vpc-f64ac68c"
  ingress {
    # TLS (change to whatever ports you need)
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    # Please restrict your ingress to only necessary IPs and ports.
    # Opening to 0.0.0.0/0 can lead to security vulnerabilities.
    cidr_blocks = "${split(",", "69.60.82.0/24,69.60.84.0/24,66.229.125.0/24,50.203.241.19/32")}"
      }
  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
    #prefix_list_ids = ["pl-12c4e678"]
  }
}
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
#-----------------------EXTERNAL BASTION HOST------------------------------------
#------------------------------------------------------------------------------
############################
#VPC_1 ## #  subnet_id     = "subnet-sg-c69cd381"
#public
############################

# Microsoft Windows Server 2016 R2 Base - ami-bf934bc0
#This instance is intended to test ThinkTecture OAuth
#  resource "aws_instance" "VPC_1-DB-2016" {
#  ami           = "ami-00a20f508263efd30"
#  instance_type = "t2.micro"
#  subnet_id     = "subnet-388ca637"
#  key_name      = "dbhaven"
#  get_password_data = "True"
#  #security_groups = ["allow_RDP"]
#  vpc_security_group_ids = ["${aws_security_group.allow_RDP.id}"]
#  #vpc_security_group_ids = [
#  #      "sg-c69cd381"
#  #  ]
#    connection {
#    password            =   "${rsadecrypt(self.password_data)}"
#    
#}#
#
#  }
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
#-----------------------KALI LINUX-----------------------------------
#------------------------------------------------------------------------------

# Kali Linux - ami-07360d1b1c9e13198

  resource "aws_instance" "Kali1" {
  ami           = "ami-07360d1b1c9e13198"
  instance_type = "t2.medium"
  subnet_id     = "subnet-388ca637"
  key_name      = "dbhaven"
  get_password_data = "False"
  private_ip    = "172.31.65.159"
  key_name      = "dbhaven"
  vpc_security_group_ids = ["${aws_security_group.allow_SSH.id}"]
  }


############################
resource "aws_iam_group" "group" {
  name = "dbhaven_misc"
  path = "/users/"
}
#------------------------------------------------------------------------------
#------------------------S3 STORAGE BUCKET-----------------------------------
#------------------------------------------------------------------------------
#############Private S3 Bucket#############
resource "aws_s3_bucket" "b" {
  bucket = "dbhaven-tf-test-bucket"
  acl    = "private"

}
###########################################

#------------------------------------------------------------------------------
#------------------------MYSQL RDS INSTANCE------------------------------
#------------------------------------------------------------------------------

resource "aws_db_instance" "default" {
  allocated_storage    = 20
  storage_type         = "gp2"
  engine               = "mysql"
  engine_version       = "5.7"
  instance_class       = "db.t2.micro"
  name                 = "mydb"
  username             = "safoo"
  password             = "barz-a-Foo"
  parameter_group_name = "default.mysql5.7"
  publicly_accessible  = "false"
  skip_final_snapshot  = "true"
}
#------------------------------------------------------------------------------
#------------------------------------------------------------------------------
#------------------------------------------------------------------------------

output "RDS Port" { value = "${aws_db_instance.default.port}" }
output "RDS Address" { value = "${aws_db_instance.default.address}" }
output "RDP security_Group_ID" { value = "${aws_security_group.allow_RDP.id}" }
output "SSH security_Group_ID" { value = "${aws_security_group.allow_SSH.id}" }
#output "AWS_VPC_1-DB-2016_Public_IP" {
#    value = "${aws_instance.VPC_1-DB-2016.public_ip}"
#}
#output "AWS_VPC_1-DB-2016_Private_IP" {
#value = "${aws_instance.VPC_1-DB-2016.private_ip}"
#}
#output "ec2_password" { value = "${rsadecrypt(aws_instance.VPC_1-DB-2016.password_data, file("/Users/jmfstgq/Downloads/dbhaven.pem"))}"}

output "AWS_Kali1_Public_IP" {
    value = "${aws_instance.Kali1.public_ip}"
}
output "AWS_Kali1_Private_IP" {
value = "${aws_instance.Kali1.private_ip}"
}


############################
# E  N  D  *****************
############################
