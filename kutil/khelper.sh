#!/bin/bash
 
printf "\n%s\n" "Kafkacat Helper"
printf "%s\n\n" "---------------"


displayMenu() {
    printf "%s\n" "1. Load config"  
    printf "%s\n" "2. View config"
    printf "%s\n" "3. View single config value"  
    printf "%s\n" "4. Consume range" 

    printf "\n%s\n\n" "Select option ... q to quit"
}

displayOption() {
    echo -e '\e[9A\e[K'
    printf "%s" "you selected option "
    printf "%s\n" "$option"
    echo -e "\033[2K"
    echo -e "\033[2K"
    echo -e "\033[2K"
    echo -e "\033[2K"   
    echo -e "\033[2K\n" 
}

#displayMenu

#read option

#displayOption
#dialog --checklist "Select:" 0 0 5 1 "consumer" off 2 "producer" off 
dialogMenu() {
    kh="$(dialog --stdout --clear --checklist "Select Kafkacat Mode" 0 0 5 \
        1 "Consumer" off \
        2 "producer" off \
        --and-widget --inputbox "Broker" 0 0 \
        --and-widget --inputbox "Topic" 0 0 \
        --and-widget --inputbox "Output Format" 0 0 \
        --and-widget --clear --checklist "Security Protocol" 0 0 5 \
            1 "Plaintext" off \
            2 "SSL" off \
            3 "SASL" off \
        --and-widget --inputbox "ssl.key.location" 0 0 \
        --and-widget --inputbox "ssl.certificate.location" 0 0 \
        --and-widget --inputbox "Username" 0 0 \
        --and-widget --inputbox "Password" 0 0 )"
  
}

mode=
broker=
topic=
format=
protocol=
sslkey=
sslcert=
username=
password=
method=
config_file=

getInputs() {
    while [[ -z $broker ]]; do
        broker="$(whiptail --inputbox "What broker do you want to connect to?" 10 50 3>&1 1>&2 2>&3 )"
    done

    while [[ -z $mode ]]; do
        mode=$(whiptail --output-fd 2 --radiolist "What action do you want to perform?" 10 35 5 \
        "1" "Consume messages" off \
        "2" "Produce messages" off \
        "3" "Get a metadata Listing" off 3>&1 1>&2 2>&3)
    done

   if [[ $mode != 3  ]]; then

    while [[ -z $topic ]]; do
        topic="$(whiptail --inputbox "Enter topic name" 10 40 3>&1 1>&2 2>&3)"
    done    

    format=$(whiptail --inputbox "Specify log format (empty for default)" 10 40 3>&1 1>&2 2>&3)

    while [[ -z $protocol ]]; do
        protocol="$(whiptail --radiolist "Security Protocol" 10 35 5 \
            1 "Plaintext" off \
            2 "SSL" off \
            3 "SASL_SSL" on 3>&1 1>&2 2>&3)"
    done

    while [[ -z $sslkey ]]; do
        sslkey=$(whiptail --inputbox "Enter path for ssl.key.location" 10 40 3>&1 1>&2 2>&3)
   #     sslkey="$(whiptail -- "Select or type path for ssl.key.location" --fselect "" 14 48 )" 
    done
# -b -C -t -o s@jklklj -X security.protocol=SASL_SSL -X sasl_mechanisms=SCRAM_SHA_256 -X ssl.ca.location=jk -X sasl_username=fdfd -X sasl.password=fdfd -f 

    while [[ -z $sslcert ]]; do
        sslcert=$(whiptail --inputbox "Enter path for ssl.certificate.location" 10 40 3>&1 1>&2 2>&3)
       # sslcert="$(dialog --stdout --title "Select or type path for ssl.certificate.location" --fselect "" 14 48 )"
    done

    while [[ -z $username ]]; do
        username=$(whiptail --inputbox "Username" 10 30 3>&1 1>&2 2>&3)
    done

    while [[ -z $password ]]; do
        password=$(whiptail --passwordbox "Password" 10 30 3>&1 1>&2 2>&3)
    done

    fi;

}

# will return key value pairs for use such as security.protocol=SASL_SSL sasl.mechanism=PLAIN
# this will be one big string that can then be split with awk and add -X in front of each
# constants=$(echo ${SITE_DATA} | jq '.SITE_DATA' | jq -r "to_entries|map(\"\(.key)=\(.value|tostring)\")|.[]")
# then this will range over and set the tags 
#for i in ${arr[@]}; do echo "-X $i"; done
loadConfiguration() {
    local error=
    local len=
    method=
    
    while [[ -z $method ]]; do
        method=$(whiptail --menu "How do you want to load configuration \n $error" 0 0 5 \
            "1" "Manually enter values" \
            "2" "Use file" 3>&1 1>&2 2>&3)
        len=${#method}

    done

    case $method in
        1)
            echo "you want to manually enter config values"
            ;;

        2)
            echo "you want to load config from a file"
            config_file=$(whiptail --inputbox "Enter config file location", 10 50 3>&1 1>&2 2>&3)
            echo $config_file

            ;;
        
    esac
}

mainMenu() {
    while [[ -z $option ]]; do
        option=$(whiptail --radiolist --notags "Welcome to KHelper, a Kafkacat helper utility\nSelectOption" 15 50 10 \
    1 "Load or update configuration" off \
    2 "Consume messages" off \
    3 "Produce messages" off \
    4 "Get metadata listing" off \
    5 "View configuration" off \
    q "Quit" off 3>&1 1>&2 2>&3)

done;

#echo $option


}
handleMenuOption() {
    case $1 in
        1)
            loadConfiguration
            echo $config_file

            ;;
        5)
            whiptail --textbox $config_file 20 50
            ;;
    esac

}

while [[ $option != 'q' ]]; do
    option=
    mainMenu
    handleMenuOption $option

done


#loadConfiguration
# dialog --msgbox "$(cat kata-deployment.yaml)" 0 0
#getInputs
#dialogMenu
#clear
echo $mode
echo $broker
echo $topic
echo $format
echo $protocol
echo $sslkey
echo $sslcert
echo $username
echo $password
echo $method

whiptail --msgbox "Mode: $mode \n\
Broker: $broker \n\
Topic: $topic \n\
Format: $format \n\
Protocol: $protocol \n\
Key Location: $sslkey \n\
Cert Location: $sslcert \n\
Username: $username \n\
Password: $password" 0 0  
echo "press enter to continue"
read i
