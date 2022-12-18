#!/bin/bash
#########################################################################################
#
#   This Script was create by Fagne Tolentio Reges
#   Date: 2022-12-17
#  
#   This function help-us manager the mysqld server and some configurations
#
#########################################################################################

f_mysql(){
#----------------------- Apache Manager Menu---------------------------------------------

# helper for waith until the user press CTL+C for exit of the shoice
wait_exit="printf '\n \n  \e[1;33m Press CTL+C for Exit \e[0m ' && watch echo '...'  $> /dev/null "

while : ; do

   shoices=$(
     dialog --stdout               \
       --backtitle "VM  $(hostname)"  \
       --title 'Iptables Manager'  \
       --menu 'Select one option' \
       0 0 0                         \
       Status       'Display mysqld Status' \
       Login        'Access the database' \
       Stop         'Stop mysqld Service' \
       Start        'Start mysqld Service' \
       Restart      'Restart mysqld Service' \
       Back         'Come Back' )

   #If CALCEL buttons was pressed,  end this section
   [ $? = 1 ] && clear &&  break
   
  case "$shoices" in
        Status)     clear; sudo systemctl status  mysql       ; eval "$wait_exit";;
        Login)      clear; sudo mysql -h localhost -u root -pweb ;;
        Stop)       clear; sudo systemctl stop mysql          ; sudo systemctl status mysql ; eval "$wait_exit";;
        Start)      clear; sudo systemctl start mysql         ; sudo systemctl status mysql ; eval "$wait_exit";;
        Restart)    clear; sudo systemctl restart mysql       ; sudo systemctl status mysql ; eval "$wait_exit";;
        Back)       clear && exit ;;
   esac

done 
}
f_mysql