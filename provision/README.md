# contrail-lab: provisioning

Provisions VMs on OpenStack

## Prerequisites

1. Download terraform https://www.terraform.io/downloads.html
2. Unzip it somewhere
3. In this directory, update terraform plugins
```
terraform init
```
4. Verify, that `.terraform` directory exists, using
```
ls -a
```

## Usage

1. Rename `secrets.tfvars.example` to `secret.tfvars`
```
mv secrets.tfvars{.example,}
```

2. Update contents of`secrets.tfvars` according to comments inside
3. From this directory, apply terraform plan
```
terraform apply -var-file="./secrets.tfvars"
```

4. When prompted whether to continue, type `yes`

