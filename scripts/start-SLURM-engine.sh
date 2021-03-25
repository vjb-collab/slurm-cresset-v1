#!/bin/bash
#
# Called as
#
# $ ./start_SLURM_engine.sh hostname port resource_type min_resource_count max_resource_count username existing_job_id

# hostname: The hostname of the broker.
# port: The broker port
# resource_type: The type of tasks the FieldEngine will run. Either "CPU" or "GPU".
# min_resource_count: The minimum number of CPU cores or GPU cards that the FieldEngine will use.
# max_resource_count: The maximum number of CPU cores or GPU cards that the FieldEngine will use, 0 means unlimited.
# username: The username of the user requesting this engine 
#           (this is indicative only as engines can and will be shared)
# existing_job_id: if present and nonzero then this is a resubmission of a previous request: check
#           if the previous job ID is still in the queue and only submit a new request if not.

BROKERHOST=$1
BROKERPORT=$2
RESOURCE_TYPE=$3
MIN_RESOURCE_COUNT=$4
MAX_RESOURCE_COUNT=$5
ENGINEUSER=$6
EXISTING_JOB_ID=$7 

##### EDIT THE SETTINGS BELOW FOR YOUR SYSTEM ####

# The SLURM options to use for single/multicore jobs
SINGLECORE_OPTIONS=       # Use default queue

# Specify options/queue for multi-core CPU jobs
#MULTICORE_OPTIONS="-p multicore.q"
MULTICORE_OPTIONS=

# Specify options/queue for GPU jobs
GPU_OPTIONS="-p gpu.p --gres=gpu:1"

# Location of the FieldEngine binary to run. We'll assume you have Flare
# installed
# 
# This should be the FieldEngine from the most recent Cresset application that
# you have installed - FieldEngines are backwards compatible.
#
[ -z "$FIELDENGINE" ] && \
    FIELDENGINE="/apps/cresset/Flare/bin/FieldEngine"

# If the FieldEngine is to service Flare jobs, you need to point this
# to the location of the Flare "third-party" directory
[ -z "$FLARE_THIRD_PARTY" ] && \
    FLARE_THIRD_PARTY="/apps/cresset/Flare/third-party"

# SLURM submission options. Add resource requests, priority etc here
SBATCH_OPTIONS="--no-requeue $SBATCH_OPTIONS"

# Make sure that the user who runs the CEBroker2 process
# has write access to the directory $NFS_SCRATCH/ceb_logs
[ -z "$NFS_SCRATCH" ] && NFS_SCRATCH=/apps/cresset/logs/
mkdir -p $NFS_SCRATCH/ceb_logs

##### END OF EDITABLE SETTINGS ####

# If the existing job ID is valid, check if it still exists
if [ ! -z "$EXISTING_JOB_ID" -a "$EXISTING_JOB_ID" != "0" ]; then
    # squeue exits with status 0 if the job exists, and 1 otherwise
    squeue -j $EXISTING_JOB_ID >/dev/null 2>&1
    if [ $? -eq 0 ]; then
        # Job still exists: return the original job ID and don't do anything further
        echo $EXISTING_JOB_ID
        exit 0
    fi
fi

if [ "$RESOURCE_TYPE" = "GPU" ]; then
    # Note that we assume that $CUDA_VISIBLE_DEVICES will be set by Slurm; FieldEngine
    # will use the value of that to decide which GPU to run on on multi-GPU systems
    SBATCH_OPTIONS="$SBATCH_OPTIONS $GPU_OPTIONS"
elif [ "$MAX_RESOURCE_COUNT" = "1" ]; then
    SBATCH_OPTIONS="$SBATCH_OPTIONS $SINGLECORE_OPTIONS"
else
    SBATCH_OPTIONS="$SBATCH_OPTIONS $MULTICORE_OPTIONS"
fi

if [ "$BROKERPORT" = "" ]; then
  echo "Error: script should be passed broker host and port"
  exit 1
fi

# FieldEngine options. -t 120 means "shut down if no tasks received for 120 secs".
# -q  means "shut down when the application using this engine stops processing."
# These will ensure that the FieldEngine job terminates when it's no longer needed
OPTIONS="-t 120 -q"

CMDFILE=/tmp/do_sbatch.$USER.$$

cat <<EOSCRIPT >$CMDFILE
#!/bin/bash

export CRESSET_THIRD_PARTY=$FLARE_THIRD_PARTY

$FIELDENGINE \
    -b $BROKERHOST:$BROKERPORT \
    $OPTIONS \
    \$FIELDENGINE_GPU_OPTIONS \
    --resource $RESOURCE_TYPE \
    --min-resource-count $MIN_RESOURCE_COUNT \
    --max-resource-count $MAX_RESOURCE_COUNT
EOSCRIPT

chmod +x $CMDFILE

output=`sbatch $SBATCH_OPTIONS \
    -J CEB.$ENGINEUSER \
    -o "$NFS_SCRATCH/ceb_logs/CEBroker2.$USER.$$.out" \
    -e "$NFS_SCRATCH/ceb_logs/CEBroker2.$USER.$$.err" \
    $CMDFILE`
jobid=`echo $output | awk '{print $NF}'`

rm -f $CMDFILE
echo $jobid