[![HIPAA](https://app.soluble.cloud/api/v1/public/badges/8b517c0a-5a0b-488b-b45f-70703bc03711.svg?orgId=854247919663)](https://app.soluble.cloud/repos/details/github.com/jeromebaude/terraform-aws-demostack?orgId=854247919663)
[![IaC](https://app.soluble.cloud/api/v1/public/badges/625c2355-cc1e-4437-8725-c5a113d8fd1a.svg?orgId=854247919663)](https://app.soluble.cloud/repos/details/github.com/jeromebaude/terraform-aws-demostack?orgId=854247919663)
[![CIS](https://app.soluble.cloud/api/v1/public/badges/4f082872-49c8-4649-a13b-91ac8b1261a7.svg?orgId=854247919663)](https://app.soluble.cloud/repos/details/github.com/jeromebaude/terraform-aws-demostack?orgId=854247919663)

# terraform-aws-demostack
    This Project configures Nomad, Vault and Consul on a variable amount of servers and workers. it already set up some nomad jobs, vault configurations and Consul queries. this is meant as a reference (and a demo enviroment) and really shouldnt be used for production. 
## Solution Diagram
![Solution Diagram](./assets/Demostack_overview.png)

## Dependencies
 <TODO>

 ### TLS

 <TODO>

 ## Consul

 <TODO>

 ## Vault

 <TODO>

 ## Nomad
 
 <TODO>

## troubleshooting
To begin debugging, check the cloud-init output:

```shell
$ sudo tail -f /var/log/cloud-init-output.log
```
