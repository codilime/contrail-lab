# contrail-lab: provisioning

Provisions VMs on OpenStack

## Prerequisites
1. Create directory
2. Download terraform https://www.terraform.io/downloads.html
3. Unzip it
4. In this directory, update terraform plugins
```
terraform init
```
5. Verify, that `.terraform` directory exists, using
```
ls -a
```
6. Clone contrail-lab

````
git clone https://github.com/codilime/contrail-lab.git
````
7. Go to conrail-lab/provision directory
8. Log in to OpenStack WebUI 
9. Copy router name and router id from Network/Routers/$router_name
10. Copy network name and network from with associated subnets from Network/Networks/$network_name
11. Fill up variables.tf file using data from Identity/Projects, Network/Routers, Network/Networks/
12. Run command 
````
./createcontrail --import-router [routerID] 
````
13. Run command
````
./createcontrail --import-network [networkID]
````
14. Run command to create conrail instance
`````
./createcontrail -c
`````
When done, you can login to your instance
````
ssh -i id_rsa centos@instance_ip
````

To recreate instance run
````
./createcontrail -d
./createcontrail -c
````


