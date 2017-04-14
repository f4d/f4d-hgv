#!/bin/bash
#
# This script is invoked by the vagrant provisioner and runs inside the vagrant instance.
# It provisions the initial environment, the runs the primary ansible playbook.
#
# This script can be run at command line:
# $ vagrant ssh
# $ sudo /bin/bash /vagrant/bin/hgv-init.sh
#
echo "
                                                           
                                                           
   -------------------------  -----------------            
  |   _    _                ||  __      __     |           
  |  | |  | |               ||  \ \    / /     |           
  |  | |__| |  __           ||   \ \  / /      |           
  |  |  __  |/ _  \         ||    \ \/ /       |           
  |  | |  | | (_| |         ||     \  /        |           
  |  |_|  |_|\__, |         ||      \/         |           
  |           __/ |___  __  ||        ___ ____ |           
  |          |___/( _ )/  \ ||       |_  )__ / |           
  |               / _ \ () |||        / / |_ \ |           
  |               \___/\__/ ||       /___|___/ |           
   -------------------------  -----------------            
                                                           
                                                           
 FFFFFFFFFFFFFFFFFFFFFF    444444444  DDDDDDDDDDDDD        
 F::::::::::::::::::::F   4::::::::4  D::::::::::::DDD     
 F::::::::::::::::::::F  4:::::::::4  D:::::::::::::::DD   
 FF::::::FFFFFFFFF::::F 4::::44::::4  DDD:::::DDDDD:::::D  
   F:::::F       FFFFFF4::::4 4::::4    D:::::D    D:::::D 
   F:::::F            4::::4  4::::4    D:::::D     D:::::D
   F::::::FFFFFFFFFF 4::::4   4::::4    D:::::D     D:::::D
   F:::::::::::::::F4::::444444::::444  D:::::D     D:::::D
   F:::::::::::::::F4::::::::::::::::4  D:::::D     D:::::D
   F::::::FFFFFFFFFF4444444444:::::444  D:::::D     D:::::D
   F:::::F                    4::::4    D:::::D     D:::::D
   F:::::F                    4::::4    D:::::D    D:::::D 
 FF:::::::FF                  4::::4  DDD:::::DDDDD:::::D  
 F::::::::FF                44::::::44D:::::::::::::::DD   
 F::::::::FF                4::::::::4D::::::::::::DDD     
 FFFFFFFFFFF                4444444444DDDDDDDDDDDDD        
                                                           
                                                           
                                                           
"

set -e
LSB=`lsb_release -r | awk {'print $2'}`

if [[ -d /vagrant ]]
then
    HOME_DIR=/vagrant
    IS_VAGRANT=1
else
    HOME_DIR=$PWD
    IS_VAGRANT=0
fi

echo
echo "Updating APT sources."
echo
apt-get update > /dev/null
echo
echo "Installing for Ansible."
echo
apt-get -y install software-properties-common
add-apt-repository -y ppa:ansible/ansible
apt-get update
apt-get -y install ansible
ansible_version=`dpkg -s ansible 2>&1 | grep Version | cut -f2 -d' '`
echo
echo "Ansible installed ($ansible_version)"

ANS_BIN=`which ansible-playbook`

if [[ -z $ANS_BIN ]]
    then
    echo "Whoops, can't find Ansible anywhere. Aborting run."
    echo
    exit
fi

echo
echo "Validating Ansible hostfile permissions. $HOME_DIR"
echo
chmod 644 $HOME_DIR/provisioning/hosts

# More continuous scroll of the ansible standard output buffer
export PYTHONUNBUFFERED=1
export ANSIBLE_FORCE_COLOR=true

# If user specified ansible extra variables file is provided, pass that in to the provisioning
if [ -e "$HOME_DIR/hgv_data/config/provisioning/ansible.yml" ] ; then
    EXTRA="@$HOME_DIR/hgv_data/config/provisioning/ansible.yml"
fi
$ANS_BIN $HOME_DIR/provisioning/playbook.yml -i'127.0.0.1,' --extra-vars "$EXTRA" --extra-vars "is_vagrant=$IS_VAGRANT"
