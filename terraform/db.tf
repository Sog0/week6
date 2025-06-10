resource "aws_db_instance" "postgres" {
  engine = "postgres"
  instance_class = "db.t3.micro"
  allocated_storage = 20
  db_name = "sampledb"
  username = "django"
  password = "password123"
  skip_final_snapshot = true
  publicly_accessible = true
  db_subnet_group_name = aws_db_subnet_group.db.name
  vpc_security_group_ids = [aws_security_group.main_sg.id]
}