terraform {
    backend "s3" {
        bucket   = "cloud-netops-lab-tfstate-440890470739"
        key    = "envs/dev/terraform.tfstate"
        region = "us-east-1"
        profile = "lab"
        use_lockfile = "true"
    }
}