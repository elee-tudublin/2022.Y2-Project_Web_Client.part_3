#!/bin/bash
#
# we can use a local mosquitto broker OR a web based one (local commented out below)
# the while will stay in the subscribe loop and act on any messages rxed
#
#vars
#
# Vars - from app settings
# IMPORTANT: These are examples - use your own values

SUPABASE_URL="https://hkpphovkobfbjqtqkvwy.supabase.co"
SUPABASE_KEY="eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJyb2xlIjoiYW5vbiIsImlhdCI6MTYyMDEyOTgzMCwiZXhwIjoxOTM1NzA1ODMwfQ.oCacU8SVPF-Oj0EEaWo8jRw8-oDL_6mAhyP1y_bJyPE"
API_ENDPOINT ="/rest/v1/events"

MY_APP='my-event-log'

# HTTP Header parameters
# Data will be JSON
REQ_HEADER='Content-type: application/json'

# Saving data to API via POST request 
REQ_METHOD='POST'

# mosquitto_sub -v -h localhost -t myapp/# | while read line
mosquitto_sub -v -h broker.hivemq.com -t $MY_APP/# | while read line
do
        # first all we do is echo the line (topic + message) to the screen
        echo $line

        # assume topic has 6 fields in form field1/field2/field3/etc...
        # cut them out of the topic and put into vars 1-3
        
        # computer_id
        topic1=`echo $line|cut -f2 -d/`
        echo $topic1

        # description
        topic2=`echo $line|cut -f3 -d/`
        echo $topic2

        # level
        topic3=`echo $line|cut -f4 -d/`
        echo $topic3

        # service
        topic4=`echo $line|cut -f5 -d/`
        echo $topic4

        # type
        topic5=`echo $line|cut -f6 -d/`
        echo $topic5

        # user
        topic6=`echo $line|cut -f7 -d/`
        echo $topic6


        # next, read  the message values for each topic
        # assume message has 6 fields in form field1,field2,field3, etc...
        # cut them out of the msg and put into vars
        msg=`echo $line|cut -f2 -d' '`

        computer_id=`echo $msg|cut -f1 -d,`
        echo $computer_id

        description=`echo $msg|cut -f2 -d,`
        echo $description

        level=`echo $msg|cut -f3 -d,`
        echo $level

        service=`echo $msg|cut -f4 -d,`
        echo $service

        type=`echo $msg|cut -f5 -d,`
        echo $type

        user=`echo $msg|cut -f6 -d,`
        echo $user

        #
        # add the event to the DB
        #
        # Data to be sent in JSON format
        JSON='{
            "computer": {"stringValue": "'"$computer_id"'"},
            "description": {"stringValue": "'"$description"'"},
            "level": {"stringValue": "'"$level"'"}, 
            "service": {"stringValue": "'"$source"'"}, 
            "type": {"stringValue": "'"$type"'"}, 
            "user": {"stringValue": "'"$user"'"}
            }'
        
        # https://askubuntu.com/questions/1162945/how-to-send-json-as-variable-with-bash-curl

        # echo to check that it looks correct
        echo $JSON

        # Use CURL to send POST request + data
        response=$(curl -X  $REQ_METHOD "$SUPABASE_URL$API_ENDPOINT" \
        -H "apikey: $SUPABASE_KEY" \
        -H "Authorization: Bearer $SUPABASE_KEY" \
        -H "$REQ_HEADER" \
        -d "$JSON")

        # Show response
        echo $response
done

# test

# this script
# ./messages.sh

# pub
# mosquitto_pub -h broker.hivemq.com -t elee-event-log/computer/description/level/service/type/user -m 3,crash,error,database,update,admin