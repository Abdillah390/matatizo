#!/bin/bash
echo 'Browserifying and uglifying'
npx browserify -v -t coffeeify --extension='.coffee' app/start.coffee | npx uglify-js > bundle.js

# Note - don't exclude node modules since this is needed for cronjob scripts
rsync --recursive --progress ./ zanzibar.cococloud.co:/var/www/analytics/

TARGETWITHPASSWORD=$1
if [ $# -lt 1 ]
  then
    printf "To update views you must specify the URL with username/password, e.g.\\n  ./deploy.sh https://admin:password@cococloud.co/zanzibar\\n"
    exit
fi

CREDENTIALS=$(echo $TARGETWITHPASSWORD | cut -f1 -d@ | cut -f 3 -d/)
TARGETNOCREDENTIALS=$(echo $TARGETWITHPASSWORD | sed "s/$CREDENTIALS@//")
DATABASE=$(echo $TARGETWITHPASSWORD | rev | cut -f1 -d/ | rev)
TARGETNODATABASE=$(echo $TARGETWITHPASSWORD | sed "s/$DATABASE//")
TARGETHOSTNAME=$(echo $TARGETWITHPASSWORD | sed "s/.*@//" | sed "s:/.*::")

echo 'Pushing all required views'
cd ../__views
./pushViews.coffee $TARGETNODATABASE
echo 'Executing (caching) all required views'
coffee executeViews.coffee $TARGETNOCREDENTIALS

# Still need to push in data from the _docs database
# TODO change this so that it only updates data from the _docs directory - couch push is slow
echo "Couchapp pushing to $TARGETWITHPASSWORD"
couchapp push $TARGETWITHPASSWORD

