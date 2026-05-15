resource "aws_iam_user" "user1" {
  name = var.username
  path = "/system/"

  tags = {
    department = "IT"
  }
}
