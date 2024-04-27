#! /bin/bash

# parameters: destination ip address, ticket id
strIP="$1"
strTicketID="$2"

# handles information parsing given a correct parameter
if [ $strTicketID == "17065" ]; then
indexNum=0;
Hostname="instance1"
elif [ $strTicketID == "17042" ]; then
indexNum=1;
Hostname="instance2"
elif [ $strTicketID == "17066" ]; then
indexNum=2;
Hostname="instance3"
else
indexNum=3;
Hostname="null"
fi

# URL of all logged tickets
strURL="https://www.swollenhippo.com/ServiceNow/systems/devTickets.php"

# gets the raw data from the url and formats in .json using jq
arrResults=$(curl -s ${strURL})

# log file handling
FILE_PATH="configurationLogs/${strTicketID}.log"
CURRENT_DATE=$(date +"%d-%b-%Y %H:%M")
strTicketIds=$(echo $arrResults | jq -r '.[].ticketID')

mkdir -p configurationLogs
echo "TicketID: $strTicketID" >> $FILE_PATH
echo "Start DateTime: ${CURRENT_DATE}" >> $FILE_PATH
echo "Requestor: $(echo $arrResults | jq -r '.['"${indexNum}"'].requestor')" >> $FILE_PATH
echo "External IP Address: $1" >> $FILE_PATH
echo "Hostname: $Hostname" >> $FILE_PATH
echo "Standard Configuration: $(echo $arrResults | jq -r '.['"${indexNum}"'].standardConfig')" >> $FILE_PATH

# debug statements
#echo $arrResults | jq '.[]'
#echo $indexNum
