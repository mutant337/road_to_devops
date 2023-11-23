bucket         = "mutant-remote-state"
key            = "state/terraform.tfstate"
region         = "eu-north-1"
encrypt        = true
dynamodb_table = "tf_lockid"