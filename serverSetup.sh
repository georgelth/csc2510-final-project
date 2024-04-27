#! /bin/bash

url="https://www.swollenhippo.com/ServiceNow/systems/devTickets.php"

arrResults=$(curl ${url})

echo $arrResults | jq
