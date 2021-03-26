# slurm-cresset-v1

This demo terraform scipt will setup and configure an HPC Slurm + Cresset Flare environment for testing and evaluation. It is intended to be deployed to a sandbox environment.    

From Cloud Shell:

```git clone https://github.com/vjb-collab/slurm-cresset-v1.git```

```cd slurm-cresset-v1/tf/examples/basic/```

```terraform init```

```vi basic.tfvars```

 ```make apply```
 
 The cluster is ready after all compute images (e.g., cluster-name-compute-x-image) have been configured and stopped. After that, put the license in place:  
 
 ```gcloud compute scp  <LICENSEFILE>  controller:~/. --zone=<zone>```
 
 The rest of the configuration takes place on the controller node. On the controller node:
 
 ```sudo mv <LICENSEFILE> /apps/cresset/licenses/.```
 
 ``` cd /apps/ ```
 
 ```sudo chown -R $USER cresset/```
 
 ```sudo chgrp -R $USER cresset/```
 
 ```cd cresset```
 
 ```./start-CEBroker.sh```
 
 ```tail -f cebroker2.log```
 
