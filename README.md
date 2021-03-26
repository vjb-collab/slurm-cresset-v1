# slurm-cresset-v1

Demo script: How to get started with Slurm + Cresset Flare on GCP

This terraform scipt will setup and configure an HPC+Cresset environment for evaluation/testing. It is intended to be deployed in a sandboxed environment.    

From Cloud Shell:

```git clone https://github.com/vjb-collab/slurm-cresset-v1.git```

```cd slurm-cresset-v1/tf/examples/basic/```

```terraform init```

```vi basic.tfvars```

 ```make apply```
 
 ```gcloud compute scp  <LICENSEFILE>  controller:~/. --zone=<zone>```
 
 On the controller node:
 
 ```sudo mv <LICENSEFILE> /apps/cresset/licenses/.```
 
 ``` cd /apps/ ```
 
 ```sudo chown -R $USER cresset/```
 
 ```sudo chgrp -R $USER cresset/```
 
 ```cd cresset```
 
 ```./start-CEBroker.sh```
 
 ```tail -f cebroker2.log```
 
