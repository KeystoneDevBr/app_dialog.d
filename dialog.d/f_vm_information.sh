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
   User:           $USER
   IP:       $(hostname -I)
   $(lsb_release -d )
   $(lsb_release -c )
   SSH Client: $SSH_CLIENT
   " 0 0
 #--------------------------------------------------------------------------------------
}
vm_information
#########################################################################################
