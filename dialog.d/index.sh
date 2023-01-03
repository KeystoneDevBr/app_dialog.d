#!/bin/bash
#########################################################################################
# This Script was create by Fagne Tolentio Reges
# Date: 2022-12-05
#
# This function call the Dialog Menu with meny options for configurate a VM
#
#########################################################################################

#----------------------- Default Menu Start----------------------------------------------

# Check if Netplan and ip was installed on Virutal Machine
if [ "$( (command -v netplan && command -v ip) | wc -l)" -ge 2 ]
  then
    netplan_menu_shoice="Netplan";
    netplan_menu_description='Show_Networking_Configuration';
    networking_menu_shoice="Networking";
    networking_menu_description="Configure_Networking_Settings";

  #elif [ "$( (command -v netplan && command -v ifconfig) | wc -l)" -ge 2 ]; then
    #echo "Work with ifconfig if it exitsts"
  fi

# Check if iptables was installed on Virtual Machine
if [ "$(command -v iptables-persistent | wc -l)" !=  0 ]
  then
    iptables_menu_shoice="Iptables";
    iptables_menu_description='Iptables_Manager';
  fi

# Check if Apache2 was installed on Virtual Machine
if [ "$(command -v apachectl | wc -l)" !=  0 ]
  then
    apache_menu_shoice="Apache";
    apache_menu_description='Apache2_Manager';
  fi

# Check if MYSQL was installed on Virtual Machine
if [ "$(command -v mysqld | wc -l)" !=  0 ]
  then
    mysql_menu_shoice="MySQL";
    mysql_menu_description='MySQL_Manager';
  fi

#Define the path for dialog app
path_app="/etc/profile.d/app_dialog.d/dialog.d"

while : ; do
  
  shoices=$(
    dialog --stdout               \
      --backtitle "VM  Manager (Version 1.0.0)"  \
      --title "VM  $(hostname)"  \
      --menu "Select one option" \
      0 0 0                         \
      Information                 'Display VM Informations' \
      $networking_menu_shoice     $networking_menu_description  \
      $netplan_menu_shoice        $netplan_menu_description \
      $iptables_menu_shoice       $iptables_menu_description \
      $apache_menu_shoice         $apache_menu_description  \
      $mysql_menu_shoice          $mysql_menu_description \
      Shell                       'Open a Shell' \
      Reboot                      'Reboot The VM' \
      Shutdown                    'Turn off VM' \
      Exit                        'End Section' )
  
  #If CALCEL buttons was pressed,  end this section
  [ $? = 1 ] && clear &&  break

  #Open a first file configuration in a netplan directory
  netplan_file="sudo vim /etc/netplan/$(ls -1 /etc/netplan/ | head -n 1)"

  case "$shoices" in
    Information)   bash "$path_app/f_vm_information.sh" ;;    
    Networking)    clear && sudo bash "$path_app/f_config_interfaces.sh"  ;;
    Netplan)       clear && eval "$netplan_file"; bash "$path_app/f_netplan_apply.sh" ;; 
    Iptables)      bash "$path_app/f_iptables.sh" ;;
    Apache)        bash "$path_app/f_apache.sh" ;;
    MySQL)         bash "$path_app/f_mysql.sh" ;;
    Shell)         clear && bash ;;
    Reboot)        clear && sudo shutdown -r now ;;
    Shutdown)      clear && sudo shutdown -h now ;;
    Exit)          clear && exit 1 ;;
   esac

done
#----------------------- Default Menu End  ----------------------------------------------

echo 'Tchau'  "$USER"
#########################################################################################
