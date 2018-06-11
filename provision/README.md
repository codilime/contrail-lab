# contrail-lab: provisioning

Provisions VMs on OpenStack

## Prerequisites

1. Download terraform https://www.terraform.io/downloads.html
2. Unzip it somewhere
3. In directory that you will run terraform from, update terraform plugins
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

2. Update contents of`secrets.tfvars`:
```
user_name = "AzureDiamond"
password = "hunter2"
ssh_key_file = "~/.ssh/path_to_pubkey_to_plant_inside_vm.pub"
```

3. Apply terraform plan
```
terraform apply -var-file="./secrets.tfvars"
```

4. When prompted whether to continue, type `yes`

