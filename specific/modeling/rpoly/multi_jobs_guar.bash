# Special comment lines to the grid engine start
# with #$ and they should contain the command-line arguments for the
# qsub command.  See 'man qsub' for more options.
#
#$ -S /bin/bash
#$ -q comp.q
#$ -t 1-10
#$ -o /home/cribb/rpoly/results/$JOB_NAME.$JOB_ID.$TASK_ID
#$ -j y
#$ -l h_rt=345600
#$ -cwd
#$ -m be -M jcribb@email.unc.edu
#
# The above arguments mean:
#       -S /bin/bash : Run this set of jobs using /bin/bash
#       -t 1-10 : Run 10 separate instances with the SGE_TASK_ID set from 1 through 10
#       -o : Put the output files in /home/cribb/rpoly/results, named by job name and ID, and task ID
#       -j y : Join the error and output files for each job
#       -l h_rt=345600 : sets time limit for run, not to exceed 345600 seconds (4 days)
#       -cwd : Run the job in the Current Working Directory (where the script is)
#       -m be -M jcribb@email.unc.edu : email jcribb@email.unc.edu when simulation is done.
#
# The following are among the useful environment variables set when each
# job is run:
#       $SGE_TASK_ID : Which job I am from the above range
#       $SGE_TASK_LAST : Last number from the above range
#               (Equal to the number of tasks if range starts with 1
#                and has a stride of 1.)

# This will be run once on each of the compute nodes selected, with the variable "$SGE_TASK" set
# to the correct instance.
# echo "This is job $SGE_TASK_ID"
matlab -nodisplay < RP_guar1p5pct.m
