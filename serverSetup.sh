#! /bin/bash

# parameters: destination ip address, ticket id
strIP="$1"
strTicketID="$2"

# URL of all logged tickets
strURL="https://www.swollenhippo.com/ServiceNow/systems/devTickets.php"

# gets the raw data from the url and formats in .json using jq
arrResults=$(curl -s ${strURL})

# log file handling
FILE_PATH='configurationLogs/'
strTicketIds=$(echo $arrResults | jq -r '.[].ticketID')
mkdir -p configurationLogs
for i in $strTicketIds
do
echo "TicketID: $i" >> $FILE_PATH/$i.log
echo "TicketID: $i"
done

# debug statements
echo $arrResults | jq '.[].ticketID'
