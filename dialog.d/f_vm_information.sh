#!/bin/bash
#########################################################################################
#
#   This Script was create by Fagne Tolentio Reges
#   Date: 2022-12-05
#
#   This function display information about the Virtual Machine
#
#########################################################################################
# VM Information Function
vm_information(){
 #----------------------- Show Information About VM-------------------------------------
 dialog \
   --backtitle "VM  $(hostname)" \
   --title "VM Information" \
   --cr-wrap \
   --msgbox "
   VM Name:   $(hostname)
   User:      $USER
   Distribution: $(lsb_release -d | awk -F: '{print $NF}')
   $(lsb_release -c )
   SSH Client: $( echo "$SSH_CLIENT" | awk '{print $1}')
   IPs:         $(hostname -I)
   " 0 0
 #--------------------------------------------------------------------------------------
}
vm_information
#########################################################################################
