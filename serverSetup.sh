#! /bin/bash

# parameters: destination ip address, ticket id
strIP="$1"
strTicketID="$2"

if [ $strTicketID == "17065" ]; then
indexNum=0;
elif [ $strTicketID == "17042" ]; then
indexNum=1;
elif [ $strTicketID == "17066" ]; then
indexNum=2;
else
indexNum=3;
fi
echo $indexNum

# URL of all logged tickets
strURL="https://www.swollenhippo.com/ServiceNow/systems/devTickets.php"

# gets the raw data from the url and formats in .json using jq
arrResults=$(curl -s ${strURL})

# log file handling
FILE_PATH='configurationLogs/'
CURRENT_DATE=$(date +"%d-%b-%Y %H:%M")
strTicketIds=$(echo $arrResults | jq -r '.[].ticketID')
mkdir -p configurationLogs
iterator=0
for i in $strTicketIds
do
echo "TicketID: $2" >> $FILE_PATH/$i.log
echo "Start DateTime: ${CURRENT_DATE}" >> $FILE_PATH/$i.log
echo "Requestor: $(echo $arrResults | jq -r '.['"${iterator}"'].requestor')" >> $FILE_PATH/$i.log
echo "External IP Address: $1" >> $FILE_PATH/$i.log
echo "Hostname: "
echo "Standard Configuration: $(echo $arrResults | jq -r '.['"${iterator}"'].standardConfig')" >> $FILE_PATH/$i.log
iterator=$((iterator+1))
done

# debug statements
#echo $arrResults | jq '.[]'
