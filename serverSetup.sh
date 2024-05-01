#! /bin/bash

# Name: serverSetup.sh
# Author: George Howard
# Class: CSC 2510
# Purpose: Provisions fresh GCP servers with packages people request through .json file. Logs the output on the new server with vital information

# parameters: destination ip address, ticket id
strIP="$1"
strTicketID="$2"

# handles information parsing given a correct parameter
if [ $strTicketID == "17065" ]; then
    indexNum=0;
    Hostname="instance-1"
elif [ $strTicketID == "17042" ]; then
    indexNum=1;
    Hostname="instance-2"
elif [ $strTicketID == "17066" ]; then
    indexNum=2;
    Hostname="instance-3"
else
    indexNum=3;
    Hostname="null"
fi

# URL of all logged tickets
strURL="https://www.swollenhippo.com/ServiceNow/systems/devTickets.php"

# gets the raw data from the url and formats in .json using jq
arrResults=$(curl -s ${strURL})

# *********************
# * LOG FILE HANDLING *
# *********************

# variables
FILE_PATH="configurationLogs/${strTicketID}.log"
CURRENT_DATE=$(date +"%d-%b-%Y %H:%M")
strTicketIds=$(echo $arrResults | jq -r '.[].ticketID')
strRequestor=$(echo $arrResults | jq -r '.['"${indexNum}"'].requestor')
strAddSpace="false"

# adds a new line correctly depending if any while loops have executed (purely for cosmetic readability)
spaceHandler(){
    if [ $1 == "true" ]; then
        echo "" >> $FILE_PATH
    fi
}

# appends to a given .log file
mkdir -p configurationLogs
echo "TicketID: $strTicketID" >> $FILE_PATH
echo "Start DateTime: ${CURRENT_DATE}" >> $FILE_PATH
echo "Requestor: ${strRequestor}" >> $FILE_PATH
echo "External IP Address: $strIP" >> $FILE_PATH
echo "Hostname: $Hostname" >> $FILE_PATH
echo "Standard Configuration: $(echo $arrResults | jq -r '.['"${indexNum}"'].standardConfig')" >> $FILE_PATH
echo "" >> $FILE_PATH

# iterates through software package information in json file
iterator=0
while [ "$(echo "${arrResults}" | jq -r ".[${indexNum}].softwarePackages[${iterator}].name")" != 'null' ]
do
    echo "softwarePackage - $(echo "${arrResults}" | jq -r ".[${indexNum}].softwarePackages[${iterator}].name") - $(date +%s)" >> $FILE_PATH
    sudo apt-get install -y $(echo "${arrResults}" | jq -r ".[${indexNum}].softwarePackages[${iterator}].install")
    strAddSpace="true"
    ((iterator++))
done

# iterates through addition configs in json file
iterator=0
while [ "$(echo "${arrResults}" | jq -r ".[${indexNum}].additionalConfigs[${iterator}].name")" != 'null' ]
do
    echo "additionalConfig - $(echo "${arrResults}" | jq -r ".[${indexNum}].additionalConfigs[${iterator}].name") - $(date +%s)" >> $FILE_PATH
    sudo $(echo "${arrResults}" | jq -r ".[${indexNum}].additionalConfigs[${iterator}].config")
    strAddSpace="true"
    ((iterator++))
done

# function call for making log files prettier
spaceHandler $strAddSpace
strAddSpace="false"

# logs and runs given package names 
iterator=0
while [ "$(echo "${arrResults}" | jq -r ".[${indexNum}].softwarePackages[${iterator}].name")" != 'null' ]
do
    packageName=$(echo "${arrResults}" | jq -r ".[${indexNum}].softwarePackages[${iterator}].install")
    version=$(sudo apt show "$packageName" | grep -Po 'Version: \K[\d.]+')
    echo "Version Check - ${packageName} - ${version}" >> "$FILE_PATH"
    sudo apt-get install -y $(echo "${arrResults}" | jq -r ".[${indexNum}].softwarePackages[${iterator}].install")
    strAddSpace="true"
    ((iterator++))
done

# pretty log file function call
spaceHandler $strAddSpace
strAddSpace="false"

# grabs ticket status from the URL and pastes the output to the last part of the .log file, marking it as complete with a UTC timestamp
arrTicketStatus=$(curl -s "https://www.swollenhippo.com/ServiceNow/systems/devTickets/completed.php?TicketID=${strTicketID}")
echo "${arrTicketStatus}" | jq -r '.[]' >> $FILE_PATH
echo "" >> $FILE_PATH
echo "Completed: $CURRENT_DATE" >> $FILE_PATH
