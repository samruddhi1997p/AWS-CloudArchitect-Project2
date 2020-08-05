# TODO: Designate a cloud provider, region, and credentials
provider "aws" {
  shared_credentials_file = "../credentials"
  region = "us-east-2"
}


# TODO: provision 4 AWS t2.micro EC2 instances named Udacity T2
resource "aws_instance" "Udacity-T2" {
  ami           = "ami-07c8bc5c1ce9598c3"
  count         = "4"
  instance_type = "t2.micro"
  subnet_id     = "subnet-00ac11765d7224efd"
  tags = {
    Name = "Udacity T2"
  }
}

# TODO: provision 2 m4.large EC2 instances named Udacity M4

 /*resource "aws_instance" "Udacit-M4" {
   ami           = "ami-07c8bc5c1ce9598c3"
   count         = "2"
   instance_type = "m4.large"
   subnet_id     = "subnet-00ac11765d7224efd"
   tags = {
     Name = "Udacity M4"
   }
 }
*/