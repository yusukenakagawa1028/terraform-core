terraform {
    backend "s3" {
        bucket         = "pvdev-terraform-backend-bucket"
        key            = "terraform.tfstate"
        region         = "ap-northeast-1"
        dynamodb_table = "terraform-state-lock-table"
        encrypt        = true
        kms_key_id     = "arn:aws:kms:ap-northeast-1:058264224939:key/5d0fdd53-9f6a-4161-bd4a-5eeca512041f"
    }
}