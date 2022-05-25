#!/usr/bin/env bash
#
#
# ==== SLURM part (resource manager part) ===== #
#
# ---- Metadata configuration ----
#
#SBATCH --job-name=CDFMT.1sTEST             # The name of your job, you'll se it in squeue.
#SBATCH --mail-type=ALL,TIME_LIMIT_50       # Mail events (ALL=BEGIN,END,FAIL,INVALID_DEPEND,REQUEUE,STAGE_OUT: TIME_LIMIT_50=50%TIME_LIMIT). 
#SBATCH --mail-user=gbellomi@sissa.it       # Where to send the mail
#
# ---- CPU resources configuration  ----
# > Clarifications at https://slurm.schedmd.com/mc_support.html 
# > but be aware of Ulysses MPI idiosyncrasies: https://www.itcs.sissa.it/services/computing/hpc  
#
#SBATCH --cpus-per-task=40                  # Number of threads per MPI rank (MAX: 2x32 cores on _partition_2, 2x20 cores on _partition_1) 
#SBATCH --nodes=1                           # Total number of requested nodes (==ntasks if cpus-per-task is set to max)
#SBATCH --ntasks-per-node=1                 # Set to 1 to be sure that different tasks run on different nodes
#SBATCH --ntasks-per-core=1                 # Set to 1 to be sure that different tasks run on different cores
#
# ---- Memory configuration ----
#
#SBATCH --mem=0                             # Memory per node (=0 takes all the available)
#
# ---- Partition, Walltime and Output ----
#
#SBATCH --partition=long1                   # Avail: regular1, regular2, long1, long2, wide1, wide2, gpu1, gpu2. Multiple partitions are possible.
#SBATCH --time=48:00:00                     # Time limit hrs:min:sec
#SBATCH --output=sLOG_%x_out%j              # Standard output log -- WARNING: %x requires a new enough SLURM. Use %j for regular jobs and %A-%a for array jobs
#SBATCH --error=sLOG_%x_err%j               # Standard error  log -- WARNING: %x requires a new enough SLURM. Use %j for regular jobs and %A-%a for array jobs
#
#
# ==== Modules part (load all the modules) ===== #
#
# ---- ITCS-mantained modules ----
#
module load gnu8/8.3.0
module load mkl/19.1.3.304
module load openmpi3/3.1.4
module load matlab/2021a
#
# ==== Info part (say things) ===== #
#
# > DO NOT MODIFY. This part prints useful info on your output file.
#
START_TIME=`date +%H:%M-%a-%d/%b/%Y`
echo '------------------------------------------------------'
echo 'This job is allocated on '$SLURM_JOB_CPUS_PER_NODE' cpu(s)'
echo 'Job is running on node(s): '
echo  $SLURM_JOB_NODELIST
echo '------------------------------------------------------'
echo 'WORKINFO:'
echo 'SLURM: job starting at           '$START_TIME
echo 'SLURM: sbatch is running on      '$SLURM_SUBMIT_HOST
echo 'SLURM: executing on cluster      '$SLURM_CLUSTER_NAME
echo 'SLURM: executing on partition    '$SLURM_JOB_PARTITION
echo 'SLURM: working directory is      '$SLURM_SUBMIT_DIR
echo 'SLURM: current home directory is '$(getent passwd $SLURM_JOB_ACCOUNT | cut -d: -f6)
echo ""
echo 'JOBINFO:'
echo 'SLURM: job identifier is         '$SLURM_JOBID
echo 'SLURM: job name is               '$SLURM_JOB_NAME
echo ""
echo 'NODEINFO:'
echo 'SLURM: number of nodes is        '$SLURM_JOB_NUM_NODES
echo 'SLURM: number of cpus/node is    '$SLURM_JOB_CPUS_PER_NODE
echo 'SLURM: number of gpus/node is    '$SLURM_GPUS_PER_NODE
echo '------------------------------------------------------'
#
# ==== End of Info part (say things) ===== #
#
cd $SLURM_SUBMIT_DIR # Brings the shell into the directory from which you’ve submitted the script.
#
# ==== JOB COMMANDS ===== #
#
# > The part that actually executes all the operations you want to do.
#   Just fill this part as if it was a regular Bash script that you want to
#   run on your computer.
#
# >> Workflows (fill and uncomment)
#matlab -batch "runDMFT.dry_line(EXE,doMPI,Uold,Ustart,Ustep,Ustop)"
mkdir CDMFT
cp inputHM2D.conf CDMFT/inputHM2D.conf
cd CDMFT
matlab -batch "runDMFT.dry_line('cdn_hm_2dsquare_bath_overhaul',true,NaN,0.0,0.1,1.0)"
matlab -batch "runDMFT.dry_line('cdn_hm_2dsquare_bath_overhaul',true,0.9,1.0,0.2,2.6)"
matlab -batch "runDMFT.dry_line('cdn_hm_2dsquare_bath_overhaul',true,2.4,2.45,0.05,3)"
matlab -batch "runDMFT.dry_line('cdn_hm_2dsquare_bath_overhaul',true,2.9,3.1,0.1,4.1)"
matlab -batch "runDMFT.dry_line('cdn_hm_2dsquare_bath_overhaul',true,4.0,4.5,0.5,6.5)"
cd ..
mkdir DMFT
cp inputHM.conf DMFT/inputHM.conf
cd DMFT
matlab -batch "runDMFT.dry_line('ed_hm_square',true,NaN,0.0,0.1,1.0)"
matlab -batch "runDMFT.dry_line('ed_hm_square',true,0.9,1.0,0.2,2.6)"
matlab -batch "runDMFT.dry_line('ed_hm_square',true,2.4,2.45,0.05,3)"
matlab -batch "runDMFT.dry_line('ed_hm_square',true,2.9,3.1,0.1,4.1)"
matlab -batch "runDMFT.dry_line('ed_hm_square',true,4.0,4.5,0.5,6.5)"
cd ..
#
#
# ==== END OF JOB COMMANDS ===== #
#
#
# Wait for processes, if any.
echo "Waiting for all the processes to finish..."
wait





