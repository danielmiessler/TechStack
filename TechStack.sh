#!/bin/bash

##############################################################
# TechStack: Find out the technologies that a site is running
#  using Bash because checking for 200's using curl seemed 
#  easier at the time but now realize I should have done it in
#  Ruby from the beginning (deep breath)
#               By Daniel Miessler (Jan 2016)
##############################################################

#########################
# Variables
#########################

SITENAME=$1
URL=$2
STACKFILE=./sitestack.txt
SITEHEADERS=./siteheaders.html
SITECONTENT=./sitecontent.html

# Cleanup
if [ -f $STACKFILE ] ; then
    rm -f $STACKFILE
fi

if [ -f $SITEHEADERS ] ; then
    rm -f $SITEHEADERS
fi

if [ -f $SITECONTENT ] ; then
    rm -f $SITECONTENT
fi

# Output
echo " "
echo " "
echo "You are scanning $SITENAME, which is located at $URL..."
echo " "

# Help
if [[ $# -ne 2 && $# -ne 3 ]] ; then
    echo 'Usage:'
    echo './TechStack sitename url'
    echo 'Example: ./TechStack google https://google.com'
    exit
fi

####################################################################################
# CHECK THE SITE
####################################################################################

# Get headers
curl -skLIA "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_10) AppleWebKit/600.1.25 (KHTML, like Gecko) Version/8.0 Safari/600.1.25" "$URL" -o ./siteheaders.html

###################
## WORDPRESS CHECKS
###################

# Check for wp-admin
WPADMIN="$(curl -skLA "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_10) AppleWebKit/600.1.25 (KHTML, like Gecko) Version/8.0 Safari/600.1.25" -w "%{http_code}" "$URL/wp-admin/" -o ./sitecontent.html)" 

# Check for readme.txt in root
WPREADME="$(curl -skLA "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_10) AppleWebKit/600.1.25 (KHTML, like Gecko) Version/8.0 Safari/600.1.25" -w "%{http_code}" "$URL/readme.txt" -o ./sitecontent.html)" 

# Check for status of requests 
if [ "$WPADMIN" = "200" ] && [ "$WPREADME" = "200" ]; then
    echo "[X] wp-admin and a readme.txt file have been found."
    echo "Wordpress" >> ./sitestack.txt
    echo "PHP" >> ./sitestack.txt
fi

# Check for Wordpress in response 
if grep -i generator ./sitecontent.html | grep -qi wordpress
then
    echo "[X] Wordpress found in headers."
    echo "Wordpress" >> ./sitestack.txt
    echo "PHP" >> ./sitestack.txt
fi

###################
## DRUPAL CHECKS
###################

# Check for drupal.js
DRUPALJS="$(curl -skLA "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_10) AppleWebKit/600.1.25 (KHTML, like Gecko) Version/8.0 Safari/600.1.25" -w "%{http_code}" "$URL/misc/drupal.js" -o ./sitecontent.html)" 

# Check for changelog 
DRUPALCHANGELOG="$(curl -skLA "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_10) AppleWebKit/600.1.25 (KHTML, like Gecko) Version/8.0 Safari/600.1.25" -w "%{http_code}" "$URL/CHANGELOG.txt" -o ./sitecontent.html)" 

# Check for status of requests 
if [ "$DRUPALJS" = "200" ] && [ "$DRUPALCHANGELOG" = "200" ]; then
    echo "[X] Drupal JS and the change log have been found."
    echo "Drupal" >> ./sitestack.txt
    echo "PHP" >> ./sitestack.txt
fi

# Check for Drupal in response 
if grep -i generator ./sitecontent.html | grep -qi drupal
then
    echo "[X] Drupal found in headers."
    echo "Drupal" >> ./sitestack.txt
    echo "PHP" >> ./sitestack.txt
fi

###################
## APACHE CHECKS
###################

# Check for Apache in response 
if grep -i "Server:" ./siteheaders.html | grep -qi apache 
then
    echo "[X] Apache found in headers."
    echo "Apache" >> ./sitestack.txt
fi

###################
## NGINX CHECKS
###################

# Check for Nginx in response 
if grep -i "Server:" ./siteheaders.html | grep -qi nginx
then
    echo "[X] Nginx found in headers."
    echo "Nginx" >> ./sitestack.txt
fi

###################
## TLS CHECKS
###################

# Check for HTTPS in redirect
if grep -i "Location:" ./siteheaders.html | grep -qi https
then
    echo "[X] TLS found in headers."
    echo "TLS" >> ./sitestack.txt
fi

if [[ "$URL" == *"https"* ]]
then
    echo "[X] TLS found in headers."
    echo "TLS" >> ./sitestack.txt
fi


#####################################################################################
# OUTPUT
#####################################################################################

if [ -f $STACKFILE ] ; then
    echo " "
    echo " "
    echo "##############################################################"
    echo "# NOTE: Tricking this tool is a Trivial Joke." 
    echo "# That being said…"
    echo "# The site APPEARS to be running the following technologies:"
    echo "##############################################################"
    echo " "
    cat ./sitestack.txt
else
    echo " "
    echo "No technologies were detected on this site."
    echo " "
fi
