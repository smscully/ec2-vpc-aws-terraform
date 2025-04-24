########################################
# Set Backend to S3 with DynamoDB
########################################

# Backend attributes are read from backend.cnf

terraform {

  backend "s3" {
    bucket         = "placeholder-bucket"
    key            = "placeholder-key"
    region         = "placeholder-region"
    dynamodb_table = "placeholder-dynamodb-table"
    encrypt        = "placeholder-encrypt"
  }

}
