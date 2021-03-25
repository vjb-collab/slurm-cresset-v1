#!/bin/bash

APP_DIR=/apps/
N_single_core_field_engines=64
N_multi_core_field_engines=32
N_gpu_field_engines=32


$APP_DIR/cresset/CEBroker2/bin/CEBroker2 -vv -p 9000 -P 9001 -e -m $N_single_core_field_engines -M $N_multi_core_field_engines -g $N_gpu_field_engines -s $APP_DIR/cresset/start-SLURM-engine.sh < /dev/null > $APP_DIR/cresset/cebroker2.log 2>&1 &