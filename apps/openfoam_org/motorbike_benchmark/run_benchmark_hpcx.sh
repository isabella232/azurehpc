#!/bin/bash

INSTALL_DIR=/apps
RUN_DIR="$1"
CASE_NAME="$2"
NODES="$3"
PPN="$4"

source $INSTALL_DIR/OpenFOAM/setenv.sh

timestamp=$(date +%Y%m%d-%H%M%S)

cd $RUN_DIR
TARGET=${CASE_NAME}-${NODES}x${PPN}-benchmark
rsync -a ${CASE_NAME}-${NODES}x${PPN}/. ${TARGET}
cd $TARGET

foamDictionary -entry writeInterval -set 1000 system/controlDict
foamDictionary -entry runTimeModifiable -set "false" system/controlDict
foamDictionary -entry functions -set "{}" system/controlDict

cat $PBS_NODEFILE | sort -u > hostlist-$timestamp
HOSTFILE=hostlist-$timestamp
NP=$(($NODES * $PPN))

PKEY=$(grep -v -e 0000 -e 0x7fff --no-filename /sys/class/infiniband/mlx5_0/ports/1/pkeys/*)
PKEY=${PKEY/0x8/0x0}

mpi_options=()
mpi_options+=(-np $NP)
mpi_options+=(--mca pml ucx)
#mpi_options+=(--mca btl self,vader,openib)
mpi_options+=(--mca btl self)
mpi_options+=(--map-by ppr:$PPN:node)
mpi_options+=(--bind-to core)
mpi_options+=(-report-bindings --display-allocation -v)
mpi_options+=(-x UCX_NET_DEVICES=mlx5_0:1)
mpi_options+=(-x UCX_IB_PKEY=$PKEY)
mpi_options+=(-x PATH -x LD_LIBRARY_PATH)
mpi_options+=(-wd $PWD)
mpi_options+=($(env |grep FOAM | cut -d'=' -f1 | sed 's/^/-x /g' | tr '\n' ' ') -x MPI_BUFFER_SIZE)

echo "${mpi_options[@]}"

mpirun "${mpi_options[@]}" -hostfile hostlist-$timestamp potentialFoam -parallel 2>&1 | tee log.potentialFoam-$timestamp
mpirun "${mpi_options[@]}" -hostfile hostlist-$timestamp simpleFoam -parallel 2>&1 | tee log.simpleFoam-$timestamp

touch case.foam
