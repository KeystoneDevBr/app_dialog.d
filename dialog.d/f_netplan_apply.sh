#!/bin/bash
#########################################################################################
#
#   This Script was create by Fagne Tolentio Reges
#   Date: 2022-12-05
#
#   This function apply the currente netplan configuration
#
#########################################################################################
#Netplan Apply Function
netplan_apply(){
 #----------------------- Apply de Ip settings -----------------------------------------
   if dialog --stdout \
       --backtitle 'IP Configuration' \
       --title "IP Settings"     \
       --yesno "Do you want apply this settings?" 7 60; then
    
     # If you were select yes to apply this settings
     dialog \
       --backtitle 'IP Configuration' \
       --title "IP Settings" \
       --msgbox "The Settigns was applied" 6 44;
    
     clear; echo "Starting apply configuration..............";
     # Apply the current network configuration
     sudo netplan try 2> /dev/null

   else
     # If you aborted the settings
     dialog \
       --backtitle 'IP Configuration' \
       --title "IP Settings" \
       --msgbox "This settings was aborted." 6 44;
   fi
 #--------------------------------------------------------------------------------------
}
netplan_apply
#########################################################################################