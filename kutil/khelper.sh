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

getInputs() {
    while [[ -z $mode ]]; do
        mode="$(dialog --stdout --clear --checklist "Select Kafkacat Mode" 0 0 5 \
        1 "Consumer" off \
        2 "Producer" off \
        3 "Metadata Listing" off )"
    done

    while [[ -z $broker ]]; do
        broker="$(dialog --stdout --clear --inputbox "Broker" 0 0)"
    done

    if [[ !$mode == 3  ]]; then

    while [[ -z $topic ]]; do
        topic="$(dialog --stdout --inputbox "Topic" 0 0)"
    done    

    while [[ -z $format ]]; do
        format="$(dialog --stdout --inputbox "log format" 0 0)"
    done

    while [[ -z $protocol ]]; do
        protocol="$(dialog --stdout --clear --checklist "Security Protocol" 0 0 5 \
            1 "Plaintext" off \
            2 "SSL" off \
            3 "SASL" on )"
    done

    while [[ -z $sslkey ]]; do
        sslkey="$(dialog --stdout --title "Select or type path for ssl.key.location" --fselect "" 14 48 )" 
    done

    while [[ -z $sslcert ]]; do
        sslcert="$(dialog --stdout --title "Select or type path for ssl.certificate.location" --fselect "" 14 48 )"
    done

    while [[ -z $username ]]; do
        username="$(dialog --stdout --inputbox "Username" 0 0)"
    done

    while [[ -z $password ]]; do
        password="$(dialog --stdout --insecure --passwordbox "Password" 0 0)"
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
    while [[ -z $method || $len > 1 ]]; do
        method="$(dialog --clear --stdout --title "$error" --checklist "How do you want to load configuration" 0 0 5 \
            1 "Manually enter values" off \
            2 "Use file" off )"
        len=${#method}
        if [[ ${#method} > 1 ]]; then 
            error="Select only one option";
        
        fi

    done

    case $method in
        1)
            getInputs
            ;;

        2)
            echo "you selected 2"
            ;;
        
    esac
}

loadConfiguration
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
