terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
}


provider "aws" {
  region = "us-east-1"
}

resource "aws_rds_cluster" "modern-engineering-aurora-postgressql-cluster" {
  cluster_identifier      = "modern-engineering-aurora-postgresql-cluster"
  engine                  = "aurora-postgresql"
  engine_version          = "11.9"
  availability_zones      = ["us-east-1a", "us-east-1b", "us-east-1c"]
  master_username         = "myusername"
  master_password         = "The.5ecret?P4ssw0rd"
  database_name           = "mydatabase"
  backup_retention_period = 5
  preferred_backup_window = "07:00-09:00"
  apply_immediately       = true
  skip_final_snapshot     = true
}

resource "aws_rds_cluster_instance" "modern-engineering-aurora-postgressql-instances" {
  count              = 2
  identifier         = "modern-engineering-aurora-postgresql-instance-${count.index}"
  cluster_identifier = aws_rds_cluster.modern-engineering-aurora-postgressql-cluster.id
  instance_class     = "db.t3.medium"
  engine             = aws_rds_cluster.modern-engineering-aurora-postgressql-cluster.engine
  engine_version     = aws_rds_cluster.modern-engineering-aurora-postgressql-cluster.engine_version
}

// from here, the database would need to be configured with the schema and data
// ENTER ANSIBLE!

# To add a table called 'movies' to the database, we would need to connect to the DB and run some commands:

# import psycopg2

# # Database connection parameters
# db_host = "your-db-endpoint"
# db_name = "your-database-name"
# db_user = "your-username"
# db_password = "your-password"
# db_port = "5432"  # Default PostgreSQL port

# # Connect to the PostgreSQL database
# conn = psycopg2.connect(
#     host=db_host,
#     database=db_name,
#     user=db_user,
#     password=db_password,
#     port=db_port
# )

# # Create a cursor object
# cur = conn.cursor()

# # SQL command to create the 'movies' table
# create_table_query = '''
# CREATE TABLE movies (
#     id SERIAL PRIMARY KEY,
#     title VARCHAR(255) NOT NULL,
#     director VARCHAR(255),
#     release_year INT,
#     genre VARCHAR(100)
# );
# '''

# # Execute the SQL command
# cur.execute(create_table_query)

# # Commit the changes
# conn.commit()

# # Close the cursor and connection
# cur.close()
# conn.close()

# print("Table 'movies' created successfully.")




