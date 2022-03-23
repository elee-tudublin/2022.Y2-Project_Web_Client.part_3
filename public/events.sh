#!/bin/bash
#
# we can use a local mosquitto broker OR a web based one (local commented out below)
# the while will stay in the subscribe loop and act on any messages rxed
#
#vars
#
# Supabase Vars - from app settings
# IMPORTANT: These are examples - use your own values
PROJECT_ID='my-event-log'

API_KEY='eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJyb2xlIjoiYW5vbiIsImlhdCI6MTYyMDEyOTgzMCwiZXhwIjoxOTM1NzA1ODMwfQ.oCacU8SVPF-Oj0EEaWo8jRw8-oDL_6mAhyP1y_bJyPE'
TOKEN='eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJyb2xlIjoiYW5vbiIsImlhdCI6MTYyMDEyOTgzMCwiZXhwIjoxOTM1NzA1ODMwfQ.oCacU8SVPF-Oj0EEaWo8jRw8-oDL_6mAhyP1y_bJyPE'

# Set per script or provide with each publish??
computer_id = 'server name'


# Build the URL to which data will be sent
# This uses the app settings defined above so that it works for your project id, collection, and API Key.
SUPABASE_URL="https://hkpphovkobfbjqtqkvwy.supabase.co/rest/v1/events"
# check url
echo $SUPABASE_URL

# HTTP Header parameters
# Data will be JSON
CONTENT_TYPE='application/json'
# Saving data to API via POST request 
REQ_METHOD='POST'
# mosquitto_sub -v -h localhost -t myapp/# | while read line
mosquitto_sub -v -h broker.hivemq.com -t $PROJECT_ID/# | while read line
do
        # first all we do is echo the line (topic + message) to the screen
        echo $line

        # assume topic has 7 fields in form field1/field2/field3/etc...
        # cut them out of the topic and put into vars 1-3
        
        # type
        topic1=`echo $line|cut -f2 -d/`
        echo $topic1

        # level
        topic2=`echo $line|cut -f3 -d/`
        echo $topic2

        # timestamp
        topic3=`echo $line|cut -f4 -d/`
        echo $topic3

        # source
        topic4=`echo $line|cut -f5 -d/`
        echo $topic4

        # computer (id)
        topic5=`echo $line|cut -f6 -d/`
        echo $topic5

        # user
        topic6=`echo $line|cut -f7 -d/`
        echo $topic6

        # description
        topic7=`echo $line|cut -f8 -d/`
        echo $topic7

        # next, read  the message values for each topic
        # assume message has 7 fields in form field1,field2,field3, etc...
        # cut them out of the msg and put into vars
        msg=`echo $line|cut -f2 -d' '`

        type=`echo $msg|cut -f1 -d,`
        echo $type

        level=`echo $msg|cut -f2 -d,`
        echo $level

        timestamp=`echo $msg|cut -f3 -d,`
        echo $timestamp

        source=`echo $msg|cut -f4 -d,`
        echo $service

        computer=`echo $msg|cut -f5 -d,`
        echo $computer_id

        user=`echo $msg|cut -f6 -d,`
        echo $user

        description=`echo $msg|cut -f7 -d,`
        echo $description

        #
        # add the event to the DB
        #
        # generate date stamp (in case timestamp is missing)
        now=`date`
        # Data to be sent in JSON format
        JSON='{"fields": {
            "type": {"stringValue": "'"$type"'"}, 
            "level": {"stringValue": "'"$level"'"}, 
            "timestamp": {"stringValue": "'"$now"'"}, 
            "service": {"stringValue": "'"$source"'"}, 
            "computer": {"stringValue": "'"$computer_id"'"}, 
            "user": {"stringValue": "'"$user"'"}, 
            "description": {"stringValue": "'"$description"'"}
            }}'
        
        # https://askubuntu.com/questions/1162945/how-to-send-json-as-variable-with-bash-curl

        # echo to check that it looks correct
        echo $JSON

        # Use CURL to send POST request + data
        response=$(curl -X POST "$SUPABASE_URL" -H "Content-Type: $CONTENT_TYPE" -H "apikey: $API_KEY" -H "Authorization: Bearer $TOKEN" --data "$JSON")

        # Show response
        echo $response
done

# test

# this script
# ./messages.sh

# pub
# mosquitto_pub -h broker.hivemq.com -t elee-event-log/type/level/timestamp/service/computer/user/description -m application,error,,database,3lfRxSiB3m0JrJ0HD1D4,admin,crash