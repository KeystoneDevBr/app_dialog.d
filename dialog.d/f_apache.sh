#!/bin/bash
#########################################################################################
#
#   This Script was create by Fagne Tolentio Reges
#   Date: 2022-12-09
#  
#   This function help-us manager the Apache2 Services.
#   This Menu show many functions for help us show/stop/start apache2 service.
#   Adictionaly this function show the current connections ative in port 80 or 443
#
#########################################################################################

f_start_menu_apache(){
#----------------------- Apache Manager Menu---------------------------------------------
while : ; do

   shoices=$(
     dialog --stdout               \
       --backtitle "VM  $(hostname)"  \
       --title 'Apache 2 Manager'  \
       --menu 'Select one option' \
       0 0 0                         \
       Status      'Display Apache 2 Status' \
       Process     'Display Apache Prcess' \
       Conections  'Show Ative Connections' \
       Stop        'Stop Apache Service' \
       Start       'Start Apache Service' \
       Reload      'Reload Apache Sercie' \
       Restart     'Restart Apache Sercie' \
       Exit        'End Section' )

   # [ $? -ne 0 ] && clear &&  break

   #If CALCEL buttons was pressed,  end this section
   [ $? = 1 ] && clear &&  break

   case "$shoices" in
       Status)     clear && sudo systemctl status apache2 ;;
       Process)    watch -n 0.1  "ps -C apache2 --forest ; echo '\n \n Press CTL+C for exit'" ;;
       Conections) watch -n 0.1 "netstat -ant | grep -E ':80|:443' ; \
                                   echo '\n\n\n Total Conections:  $(ss -ant | grep -E ':80|:443' | wc -l )'; \
                                   echo '\n\n\n Press CTRL+C for exit;'" ;;
       Stop)       clear; sudo systemctl stop apache2 && sudo systemctl status apache2 ;;
       Start)      clear; sudo systemctl start apache2 && sudo systemctl status apache2 ;;
       Reload)     clear; sudo /etc/init.d/apache2 force-reload && sudo systemctl status apache2 ;;
       Restart)    clear; sudo /etc/init.d/apache2 restart  && sudo systemctl status apache2 ;;
       Exit)       clear && exit ;;
   esac

done
}
f_start_menu_apache