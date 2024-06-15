docker run -d --name slurmnode8x \
--rm \
--hostname slurmnode8x \
-p 16818:6818 \
--add-host slurmmaster:192.168.0.33 \
--add-host slurmnode8:192.168.0.12 \
--gpus all \
slurm-node:latest \
bash
