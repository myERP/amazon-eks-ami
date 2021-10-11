#!/usr/bin/env bash
#
# Clean up additional YUM repositories, typically used for security patches.
# The format of ADDITIONAL_YUM_REPOS is: "repo=patches-repo,name=Install patches,baseurl=http://amazonlinux.$awsregion.$awsdomain/xxxx,priority=10"
# Multiple yum repos can be specified, separated by ';'

################################################################################
### Cleanup ####################################################################
################################################################################

# Clean up yum caches to reduce the image size
#sudo $PACKAGE_MANAGER_CLEAN
sudo rm -rf \
    $TEMPLATE_DIR \
    $CACHE_DIR

# Clean up files to reduce confusion during debug
## WE MOVED THIS FROM INSTALL-WORKER.SH as we need it during the hardening stage
sudo rm -rf \
    /etc/hostname \
    /etc/machine-id \
    /etc/resolv.conf \
    /etc/ssh/ssh_host* \
    /root/.ssh/authorized_keys \
    /home/ec2-user/.ssh/authorized_keys \
    /var/lib/cloud/data \
    /var/lib/cloud/instance \
    /var/lib/cloud/instances \
    /var/lib/cloud/sem \
    /var/lib/dhclient/* \
    /var/lib/dhcp/dhclient.* \
    /var/lib/yum/history \
    /var/log/cloud-init-output.log \
    /var/log/cloud-init.log \
    /var/log/secure \
    /var/log/wtmp

sudo touch /etc/machine-id



if [ -z "${ADDITIONAL_YUM_REPOS}" ]; then
  echo "no additional yum repo, skipping"
  exit 0
fi


AWK_CMD='
BEGIN {RS=";";FS=","}
{
  delete vars; 
  for(i = 1; i <= NF; ++i) { 
    n = index($i, "="); 
    if(n) { 
      vars[substr($i, 1, n-1)] = substr($i, n + 1)
    }
  } 
  Repo = "/etc/yum.repos.d/"vars["repo"]".repo"
}
{cmd="rm -f " Repo; system(cmd)}
'
sudo awk "$AWK_CMD" <<< "${ADDITIONAL_YUM_REPOS}"