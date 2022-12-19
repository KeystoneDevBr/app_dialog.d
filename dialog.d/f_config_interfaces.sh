#!/bin/bash
#########################################################################################
#
#   This Script was create by Fagne Tolentio Reges
#   Date: 2022-12-17
#
#   This function help us to configure Static IP Address by Netplan (Default on Ubuntu)
#   For do it, it call the Dialog navigation for colect the informations an apply the
#   new configurtaions.
#
#########################################################################################
f_config_ip(){
#########################################################################################
    
    #Get the mac address from each one interface available   
    my_macs=$(ip add | grep link/ether | awk '{print $2}')
    
    #counts the number of interfaces
    qtd_mac=$(echo "$my_macs" | wc -w)
    
    #Define the default name for file configuration
    netplan_file="dialog-netplan-set.yaml"


    f_select_interface(){
        #Prepare the options for menu, like this:
        #int_options="0  Interface_Eth0"
        int_options=""
        i=0
        until [[ i -eq $qtd_mac ]]; do #Checks if i=10
            int_options="${int_options} ${i} Interface_Eth${i}"
            i=$((i+1)) #Increment i by 1
        done

        selected_int=$(
            dialog --stdout               \
            --backtitle "VM  $(hostname)"  \
            --title 'Configure Interfaces'  \
            --menu 'Select one Inferface' \
            0 0 0                         \
            $int_options )
        
        return=$?
        # Exit if CALCEL button pressed
        [ $return -eq 255   ] && return 1 # Esc
        [ $return -eq 1 ] && return 1     # Cancel

        return 0
    }
    
    f_select_action(){
        selected_action="";
        selected_action=$(
            dialog --stdout               \
            --backtitle "VM  $(hostname)"  \
            --title "Interface Eth$selected_int"  \
            --menu 'Select Configuration' \
            0 0 0                         \
            STAT "Static Configuration" \
            DHCP "Enable DHCP"      \
            DIS  "Disable Interface" )
            
        case "$selected_action" in
            STAT) 
                next_step='step2'
                return 0
            ;;
            DHCP) 
                can_save=$(dialog --stdout \
                   --backtitle 'IP Configuration' \
                   --title "Interface Eth$selected_int"     \
                   --cr-wrap \
                   --yesno "
                       Do you want save this sattings?:

                       Interface:      Eth$selected_int
                       IP Address:     DHCP
                  
                   " 0 0)

                if [ $? -eq 0 ] ; then
                    # Enable DHCP 
                    sudo netplan set "network.ethernets.eth$selected_int={addresses: NULL, nameservers: NULL, gateway4: NULL, dhcp4: true, routes: NULL}" 2> /dev/null;
                    clear; sudo netplan try 2> /dev/null;
                else
                    next_step='step0'
                    return 0
                fi
                return 1
            ;;
            DIS) 
                can_save=$(dialog --stdout \
                   --backtitle 'IP Configuration' \
                   --title "Interface Eth$selected_int"     \
                   --cr-wrap \
                   --yesno "
                       Do you want disable this interface?:

                       Interface:      Eth$selected_int
                       Disabled
                   " 0 0)

                if [ $? -eq 0 ] ; then
                    # Disabling interfaces 
                    sudo netplan set "network.ethernets.eth$selected_int={addresses: NULL, nameservers: NULL, gateway4: NULL, dhcp4: false, routes: NULL}" 2> /dev/null;
                    clear; sudo netplan try 2> /dev/null;
                else
                    next_step='step0'
                    return 0
                fi
                return 1
            ;;
        esac
        
        return=$?
        # Exit if CALCEL button pressed
        [ $return -eq 255   ] &&  return 1 # Esc
        [ $return -eq 1 ] &&  return 1    # Cancel

    }

    f_format_netplan_file(){
        #remove all networking file configuration
        sudo rm -rf /etc/netplan/* ;
        
        #Create a new networking file configuration
        sudo touch "/etc/netplan/$netplan_file"

        #Create the first interface. Don't change the echo identation.
        echo \
        "network:
        version: 2
        renderer: networkd
        ethernets:
            eth0:
                dhcp4: true" > /etc/netplan/$netplan_file
        
        #Separates the line macs by space (" ") and takes one by key_mac
        get_first_mac=$(echo $my_macs | cut -d " " -f1)

        #Rename the first ethernet 
        sudo netplan set "network.ethernets.eth0={ set-name: "eth0", match: {name: "eth0", macaddress: "$get_first_mac"}}"  2>/dev/null;     

        # This loop add more interfaces, if exists
        i=1
        until [[ i -eq $qtd_mac ]]; do #Checks if i=10
            #Add more interfaces if exists, and rename it. Don't change the echo identation.
            echo \
            "    eth${i}:
            dhcp4: true" >> /etc/netplan/$netplan_file
        
            #Especify the mac for extration from the line ($my_mac is one line with many mac address)
            key_mac=$((i+1))
        
            #Separates the line macs by space (" ") and takes one by key_mac
            get_one_mac=$(echo $my_macs | cut -d " " -f$key_mac)

            sudo netplan set "network.ethernets.eth$i={ set-name: "eth$i", match: {name: "eth$i", macaddress: "$get_one_mac"}}"  2>/dev/null;     
        
            i=$((i+1)) #Increment i by 1
        done

        return 0
    }    
    
    #Append new interface in the file configuration
    f_append_int(){

            echo \
            "    eth${selected_int}:
            dhcp4: true" >> /etc/netplan/$netplan_file
        #Get all mac address from interfaces available
        my_macs=$(ip add | grep link/ether | awk '{print $2}')
        
        #Especify the mac for extration from the line ($my_mac is one line with many mac address)
        key_mac=$(($selected_int+1))
        
        #Separates the line macs by space (" ") and takes one by key_mac
        get_one_mac=$(echo $my_macs | cut -d " " -f$key_mac)

        sudo netplan set "network.ethernets.eth$selected_int={ set-name: "eth$selected_int", match: {name: "eth$selected_int", macaddress: "$get_one_mac"}}"  2>/dev/null;     
       
    }

    #Applay the Settings for selected interface
    f_apply_settings(){
        
        #Check for a specific file created by dialog 
        FILE="/etc/netplan/$netplan_file"
        #if file existe, configure the interface selected
        if [ -f "$FILE" ]; then
            #check if there is interface in the file configuration. (Return 0 if alrady exists or 1 if not)
            check_int=$(sudo netplan get  ethernets.eth$selected_int 2>/dev/null | grep null -c )
            if [ "$check_int" -eq 0 ]; then
                #Save Changes
                clear; echo "Starting apply configuration..............";
                #Crelar all configuration brefore apply
                sudo netplan set "network.ethernets.eth$selected_int={addresses: NULL, nameservers: NULL, gateway4: NULL, dhcp4: false, routes: NULL}" 2> /dev/null;
                # Write the new Configurations
                sudo netplan set "network.ethernets.eth$selected_int={addresses: ["$address$netmask"], gateway4: "$gateway", nameservers: { addresses: ["$name_servers"], search: [""]}}" 2> /dev/null ;
                # Trat apply new configurations
                sudo netplan try 2> /dev/null
            else
                #Append interface input int the file
                f_append_int
                 #try aggan
                f_apply_settings               
            fi     
        else 
            #If the file do not extis create it
            f_format_netplan_file
            #try aggan
            f_apply_settings
        fi
    }

    ########################################################################################

    # Start the navigation (the first step is step0)
    next_step='step0'

    while : ; do
       case "$next_step" in
           #Fist step, get the ip address.
           step0)
                next_step='step1' 
                f_select_interface;
                ;;
           step1)
                f_select_action;
                ;;
           step2)
                next_step='step3'
                address=$(dialog --stdout \
                   --max-input 15 \
                   --backtitle 'IP Configuration' \
                   --title "Interface Eth$selected_int"     \
                   --inputbox 'Enter with IP address: X.X.X.X'  0 0 "192.168.1.1")
               ;;
           step3)
               next_step='step4'
               netmask=$(dialog --stdout \
                   --max-input 3 \
                   --backtitle 'IP Configuration' \
                   --title "Interface Eth$selected_int"     \
                   --inputbox 'Enter With Mask (CIDR Prefix): /X'  0 0 "/24")
               ;;
           step4)
               next_step='step5'
               gateway=$(dialog --stdout \
                   --max-input 15 \
                   --backtitle 'IP Configuration' \
                   --title "Interface Eth$selected_int"     \
                   --inputbox 'Enter with IP Gateway: X.X.X.X'  0 0 "192.168.1.254")
               ;;
           step5)
               next_step='step6'
               name_servers=$(dialog --stdout \
                   --max-input 31 \
                   --backtitle 'IP Configuration' \
                   --title "Interface Eth$selected_int"     \
                   --inputbox 'Enter with the Servers Names IP: X.X.X.X, \
                      You can use (,) for separate the server Names'  0 0 "8.8.8.8")
               ;;
           step6)
               next_step='step7'
               can_save=$(dialog --stdout \
                   --backtitle 'IP Configuration' \
                   --title "Interface Eth$selected_int"     \
                   --cr-wrap \
                   --yesno "
                       Do you want save this sattings?:
                        
                       Interface:      Eth$selected_int
                       IP Address:     $address
                       Gateway:        $gateway
                       DNS:            $name_servers
                  
                   " 0 0)
               ;;
           step7)
               next_step='step0'
               dialog \
                   --cr-wrap \
                   --backtitle 'IP Configuration' \
                   --title "Interface Eth$selected_int"     \
                   --msgbox "
                       This settings will be saved:

                       Interface:      Eth$selected_int
                       IP Address:     $address
                       Gateway:        $gateway
                       DNS:            $name_servers

                   " 14 40
                    
                    f_apply_settings ; break
               ;;


           *)
               echo "Janela desconhecida '$next_step'"
               echo "Abortando programa..."
               exit
       esac

       # Get the CANCEL, ESC events
       return=$?
       # Start navigation with ESC pressed
       [ $return -eq 255   ] && next_step="step0"      # Esc
       # Exit if CALCEL button pressed
       [ $return -eq 1 ] && clear && break             # Cancel

   done
   #------------------------------------------------------------------------------------
}
f_config_ip
#########################################################################################