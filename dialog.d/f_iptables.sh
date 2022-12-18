#!/bin/bash
#########################################################################################
#
#   This Script was create by Fagne Tolentio Reges
#   Date: 2022-12-09
#  
#   This function help-us manager the iptables configuration.
#
#########################################################################################

f_iptables(){
#----------------------- Apache Manager Menu---------------------------------------------

# helper for waith until the user press CTL+C for exit of the shoice
wait_exit="printf '\n \n  \e[1;33m Press CTL+C for Exit \e[0m ' && watch echo '...'  $> /dev/null "

# Configure command for disable iptables rules.
disable_iptable="
   sudo iptables -P INPUT ACCEPT && \
   sudo iptables -P FORWARD ACCEPT && \
   sudo iptables -P OUTPUT ACCEPT && \
   sudo iptables -F && \
   sudo iptabls -X ; \
   clear ;  sudo iptables -L -n -v "

while : ; do

   shoices=$(
     dialog --stdout               \
       --backtitle "VM  $(hostname)"  \
       --title 'Iptables Manager'  \
       --menu 'Select one option' \
       0 0 0                         \
       Status      'Display Iptables Status' \
       Show        'Display Iptables Running Configuration' \
       Config      'Open The File Configuration' \
       Apply       'Applay The File Configuration ' \
       Restart     'Restart Iptables Service' \
       Disable     'Disable Firewall'\
       Back        'Come Back' )

   #If CALCEL buttons was pressed,  end this section
   [ $? = 1 ] && clear &&  break
   
  case "$shoices" in
        Status)     clear; sudo systemctl status iptables  ; eval "$wait_exit";;
        Show)       clear; sudo iptables -L -n -v && eval "$wait_exit";;
        Config)     clear && sudo vim /etc/iptables/rules.v4 ;;
        Apply)      clear; sudo systemctl force-reload iptables  ; sudo systemctl status iptables ; eval "$wait_exit";;
        Stop)       clear; sudo systemctl stop iptables          ; sudo systemctl status iptables ; eval "$wait_exit";;
        Start)      clear; sudo systemctl start iptables         ; sudo systemctl status iptables ; eval "$wait_exit";;
        Restart)    clear; sudo systemctl restart iptables       ; sudo systemctl status iptables ; eval "$wait_exit";;
        Disable)    clear; eval "$disable_iptable" && printf " \n \n \e[1;31mThe Firwall was DISABLED!!!\n \n Obs.: The Firwall will be enable automatically after the VM reboot \e[0m \n" ; eval "$wait_exit" ;;
        Back)       clear && exit ;;
   esac

done 
}
f_iptables