#!/bin/bash

# sudo chmod 400 /etc/munge/munge.key
# sudo chown munge:munge /etc/munge/munge.key

# user home permission
sudo chown admin:admin -R /home/admin

# start services
sudo service munge start
echo "---> MUNGE status ..."
munge -n | unmunge | grep STATUS

sudo service slurmctld start

# source /etc/profile.d/lmod.sh
# module --version

## Init slurm acct database
#IS_DATABASE_EXIST='0'
#while [ "1" != "$IS_DATABASE_EXIST" ]; do
##    echo "Waiting for database $MARIADB_DATABASE on $MARIADB_HOST..."
#    IS_DATABASE_EXIST="`mysql -h $MARIADB_HOST -u root -p"$MARIADB_ROOT_PASSWORD" -qfsBe "select count(*) as c from information_schema.schemata where schema_name='$MARIADB_DATABASE'" -H | sed -E 's/c|<[^>]+>//gi' 2>&1`"
#    sleep 5
#done

#environment check spack
source /tools/spack/share/spack/setup-env.sh
spack --version

#environment check easybuild
eb --version
eb --show-system-info
eb --show-config

eb bzip2-1.0.6.eb

#environment check lmod
source /etc/profile.d/lmod.sh
#source /opt/focal/lmod/lmod/init/bash
module --version
#module use ~/.local/easybuild/modules/
module avail

sleep 3
sudo service slurmctld restart

sinfo

tail -f /dev/null
