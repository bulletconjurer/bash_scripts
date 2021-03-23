#!/bin/bash

#Log analysis for NCL



#SSH first (easy ig)

#Colors
RED='\033[0;31m' #hostname
GREEN='\033[0;32m'
GREY='\033[1;30m'
ORANGE='\033[0;33m'
#reset text to normal
reset=`tput sgr0`


read -p "Give me the name/file location: " log

##Adds a pause statement
pause(){
	read -p "Press [Enter] key to continue..." fakeEnter
}

menu=$(cat menu.txt)

echo "            _        _______  _______    _______  _        _______  _              _______ _________ _______  "		
echo "	   ( \      (  ___  )(  ____ \  (  ___  )( (    /|(  ___  )( \   |\     /|(  ____ \\__   __/(  ____ \ "
echo "	   | (      | (   ) || (    \/  | (   ) ||  \  ( || (   ) || (   ( \   / )| (    \/   ) (   | (    \/ "
echo "	   | |      | |   | || |        | (___) ||   \ | || (___) || |    \ (_) / | (_____    | |   | (_____  "
echo "	   | |      | |   | || | ____   |  ___  || (\ \) ||  ___  || |     \   /  (_____  )   | |   (_____  ) "
echo "	   | |      | |   | || | \_  )  | (   ) || | \   || (   ) || |      ) (         ) |   | |         ) | "
echo "	   | (____/\| (___) || (___) |  | )   ( || )  \  || )   ( || (____/\| |   /\____) |___) (___/\____) | "
echo "	   (_______/(_______)(_______)  |/     \||/    )_)|/     \|(_______/\_/   \_______)\_______/\_______) "
echo "																										  "
echo "1) SSH log"
echo "2) nginx log"
echo "9) change_log"
echo "0) exit"


SSH(){
	#This is an example of "i don't know if this is special or not" i just have to try this with a different log from SSH maybe idk
	echo "$log has been chosen as an SSH log, removing info"
	


	hostname=$(cat $log | awk '{print $4; exit}')
	#This works today but might need to be changed in the future, idk the first ip is 0.0.0.0 that's why it's head -2 and not head -1
	first_ip=$(grep -Eo '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' $log | sed -n 2p)
	#creates a temporary log so that i can grep for the next ip
	new_log=$(grep -v $first_ip $log > temp.log)
	second_ip=$(grep -Eo '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' temp.log | sed -n 2p)
	another_log=$(grep -v $second_ip temp.log > alsotemp.log)
	third_ip=$(grep -Eo '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' alsotemp.log | sed -n 2p)
	#this mostly doesn't need to be changed
	user=$(cat $log | grep 'Failed password for ' | cut -d" " -f9 | head -1)
	rogue_ip=$(cat $log | grep 'Accepted password for' | grep -Eo '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}')

	echo -e "${RED}Hostname:${reset}$hostname"
	echo -e "${GREEN}First Ip:${reset}$first_ip"
	echo -e "${GREEN}Second Ip:${reset}$second_ip"
	echo -e "${GREEN}Third Ip:${reset}$third_ip"
	echo -e "${ORANGE}user being attacked:${reset} $user"
	echo -e "${GREY}ip with successful login:${reset} $rogue_ip"
	pause

		
}

nginx(){
	clear
	echo "$log has been chosen as an nignx log, removing info"

	number_of_ips=$(cat $log | cut -d " " -f 1 | sort | uniq -c | wc -l)
	status_codes=$(cat $log | cut -d '"' -f3 | cut -d ' ' -f2 | sort | uniq -c | sort -rn )

	echo -e "${GREEN}number of different ips that reached the server: ${reset} $number_of_ips"
	echo -e "${RED}number of different statuses:"
	echo -e "${reset} $status_codes"

}



change_log(){
	read -p "give me the location/name of the log: " log
}

read_options() { 
	local choice
	read -p "Please select the type of log: " choice

	case $choice in 
		1) SSH;;
		2) nginx;;
		9) change_log;;
		0) exit;;
		*) echo "Sorry that's not a valid choice, please select another one...";;
	esac 
	
}


#This runs the actual script
while true
do
	echo $menu
	read_options
done
