#! /bin/bash

# parameters: destination ip address, ticket id
strIP="$1"
strTicketID="$2"

# URL of all logged tickets
strURL="https://www.swollenhippo.com/ServiceNow/systems/devTickets.php"

# gets the raw data from the url and formats in .json using jq
arrResults=$(curl ${strURL})

# log file handling

# debug statements
echo $arrResults | jq
