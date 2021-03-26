# slurm-cresset-v1

Demo script: How to get started with Slurm + Cresset Flare on GCP

This is based on v1 of the SchedMD Slurm GCP scripts. 

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
 
 ```./start-CEBroker.sh```
 
 ```tail -f cebroker2.log```
 
