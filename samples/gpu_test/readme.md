

## Overview
reference: https://github.com/dholt/slurm-gpu/blob/master/README.md

Slurm overview: https://slurm.schedmd.com/overview.html

> Slurm is an open source, fault-tolerant, and highly scalable cluster management and job scheduling system for large and small Linux clusters. Slurm requires no kernel modifications for its operation and is relatively self-contained. As a cluster workload manager, Slurm has three key functions. First, it allocates exclusive and/or non-exclusive access to resources (compute nodes) to users for some duration of time so they can perform work. Second, it provides a framework for starting, executing, and monitoring work (normally a parallel job) on the set of allocated nodes. Finally, it arbitrates contention for resources by managing a queue of pending work. Optional plugins can be used for accounting, advanced reservation, gang scheduling (time sharing for parallel jobs), backfill scheduling, topology optimized resource selection, resource limits by user or bank account, and sophisticated multifactor job prioritization algorithms.

## GPU resource scheduling in Slurm

### Simple GPU scheduling with exclusive node access

Slurm supports scheduling GPUs as a consumable resource just like memory and disk. If you're not interested in allowing multiple jobs per compute node, you many not nessesarily need to make Slurm aware of the GPUs in the system, and the configuration can be greatly simplified.

One way of scheduling GPUs without making use of GRES (Generic REsource Scheduling) is to create partitions or queues for logical groups of GPUs. For example, grouping nodes with P100 GPUs into a P100 partition:

```console
$ sinfo -s
PARTITION AVAIL  TIMELIMIT   NODES(A/I/O/T)  NODELIST
p100     up   infinite         4/9/3/16  node[212-213,215-218,220-229]
```

Partition configuration via Slurm configuration file `slurm.conf`:

```console
NodeName=node[212-213,215-218,220-229]
PartitionName=p100 Default=NO DefaultTime=01:00:00 State=UP Nodes=node[212-213,215-218,220-229]
```

### Scheduling resources at the per GPU level

Slurm can be made aware of GPUs as a consumable resource to allow jobs to request any number of GPUs.

This feature requires job accounting to be enabled first; for more info, see: https://slurm.schedmd.com/accounting.html

The Slurm configuration file needs parameters set to enable cgroups for resource management and GPU resource scheduling:

`slurm.conf`:

```console
# General
ProctrackType=proctrack/cgroup
TaskPlugin=task/cgroup

# Scheduling
SelectType=select/cons_res
SelectTypeParameters=CR_Core_Memory

# Logging and Accounting
AccountingStorageTRES=gres/gpu
DebugFlags=CPU_Bind,gres                # show detailed information in Slurm logs about GPU binding and affinity
JobAcctGatherType=jobacct_gather/cgroup
```

Partition information in `slurm.conf` defines the available GPUs for each resource:

```console
# Partitions
GresTypes=gpu
NodeName=slurm-node-0[0-1] Gres=gpu:2 CPUs=10 Sockets=1 CoresPerSocket=10 ThreadsPerCore=1 RealMemory=30000 State=UNKNOWN
PartitionName=compute Nodes=ALL Default=YES MaxTime=48:00:00 DefaultTime=04:00:00 MaxNodes=2 State=UP DefMemPerCPU=3000
```

Cgroups require a seperate configuration file:

`cgroup.conf`:

```console
CgroupAutomount=yes 
CgroupReleaseAgentDir="/etc/slurm/cgroup" 

ConstrainCores=yes 
ConstrainDevices=yes
ConstrainRAMSpace=yes
#TaskAffinity=yes
```

GPU resource scheduling requires a configuration file to define the available GPUs and their CPU affinity

`gres.conf`:

```console
Name=gpu File=/dev/nvidia0 CPUs=0-4
Name=gpu File=/dev/nvidia1 CPUs=5-9
```

Running jobs utilizing GPU resources requires the `--gres` flag; for example, to run a job requiring a single GPU:

```console
$ srun --gres=gpu:1 nvidia-smi
```

In order to enforce proper CPU:GPU affinity (i.e. for performance reasons), use the flag `--gres-flags=enforce-binding`

> --gres-flags=enforce-binding
If set, the only CPUs available to the job will be those bound to the selected GRES (i.e. the CPUs identified in the gres.conf file will be strictly enforced rather than advisory). This option may result in delayed initiation of a job. For example a job requiring two GPUs and one CPU will be delayed until both GPUs on a single socket are available rather than using GPUs bound to separate sockets, however the application performance may be improved due to improved communication speed. Requires the node to be configured with more than one socket and resource filtering will be performed on a per-socket basis. This option applies to job allocations.


### Kernel configuration

Using memory cgroups to restrict jobs to allocated memory resources requires setting kernel parameters

On Ubuntu systems this is configurable via `/etc/default/grub`

> GRUB_CMDLINE_LINUX="cgroup_enable=memory swapaccount=1"

## Step-by-step instructions
See: https://github.com/mknoxnv/ubuntu-slurm

## Building newer versions of Slurm from source as .deb packages for Ubuntu or .rpm for Centos

### Install dependencies

#### Ubuntu

```console
sudo apt-get install build-essential ruby-dev libpam0g-dev libmysqlclient-dev libmunge-dev libmysqld-dev
```

#### Centos

```console
sudo yum groupinstall -y "Development Tools"
sudo yum install -y bzip2 wget ruby-devel libmunge-devel pam-devel perl-devel
wget https://repo.mysql.com//mysql80-community-release-el7-1.noarch.rpm && \
    sudo rpm -i mysql80-community-release-el7-1.noarch.rpm && \
    sudo yum install -y mysql-community-devel && \
    rm mysql80-community-release-el7-1.noarch.rpm 
```

### Install FPM packaging tool

> fpm - https://github.com/jordansissel/fpm

```console
sudo gem install fpm
```

### Configure and build Slurm

```console
export SLURM_VERSION=17.11.12
wget http://www.schedmd.com/downloads/latest/slurm-${SLURM_VERSION}.tar.bz2
tar xvjf slurm-${SLURM_VERSION}.tar.bz2
./configure --prefix=/tmp/slurm-build --sysconfdir=/etc/slurm
make -j
make -j contrib
make -j install
```

### Package Slurm install directory as a Debian package using FPM

> Modify version via `-v` flag for source version changes, and `--iteration` flag for build version cahnges so that APT will detect updated packages

```console
export BUILD_ITERATION=1
fpm -s dir -t deb -v ${SLURM_VERSION} --iteration ${BUILD_ITERATION} -n slurm --prefix=/usr -C /tmp/slurm-build .
```
A deb package such as `slurm_17.11.12-2_amd64.deb` has been created in the same directory. You may inspect its contents using:
```console
dpkg --contents slurm_${SLURM_VERSION}-${BUILD_ITERATION}_amd64.deb
```

## Build with docker (preferred method)

> Assumes `docker` is already installed.

The Dockerfile and Makefile provided in this repo wraps the above build-and-package-as-deb steps into a containerized workflow.
The deb package also copies the customary `copyright` license file from the source archive to the appropriate `/usr/share/doc` location.

If you need to update the Slurm source version, make necessary version string changes in `Makefile` prior to the `make` step:

```console
git clone https://github.com/dholt/slurm-gpu
cd slurm-gpu/
make BUILD_DISTRO=ubuntu # For Centos, use BUILD_DISTRO=centos
```

For Ubuntu, a nicely packaged `slurm_17.11.12-2_amd64.deb` should now exist in the same directory.
Inspect the contents using `dpkg --contents slurm_17.11.12-2_amd64.deb`

For Centos, a nicely packaged `slurm-17.11.12-2.x86_64.rpm` should now exist in the same directory.
Inspect the contents using `rpm -qlp slurm-17.11.12-2.x86_64.rpm`
