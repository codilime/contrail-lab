# contrail-lab: provisioning

Provisions VMs on OpenStack

## Prerequisites
1. Clone contrail lab repository
````
git clone https://github.com/codilime/contrail-lab.git
````
2. Go to contrail-lab/provision directory
````
cd contrail-lab/provision directory
````
3. Download terraform https://www.terraform.io/downloads.html to contrail-lab/provision directory
4. Unzip it
5. Run command
```
terraform init
```
6. Verify, that `.terraform` directory exists, using
```
ls -a
```
7. Log in to OpenStack WebUI 
8. Copy router name and router id from Network/Routers/router_name
9. Copy network name and network id from with associated subnets from Network/Networks/network_name
10. Fill up variables.tf file using data from Identity/Projects, Network/Routers, Network/Networks/
11. Run command 
````
./createcontrail --import-router [routerID] 
````
12. Run command
````
./createcontrail --import-network [networkID]
````
13. Run command to create conrail instance
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


