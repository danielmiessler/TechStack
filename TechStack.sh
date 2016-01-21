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

URL=$1
STACKFILE=./sitestack.txt
SITECONTENT=./sitecontent.html
OUTPUT=./output.html
SORTEDSITESTACK=./sortedsitestack.txt

# Cleanup
if [ -f $STACKFILE ] ; then
    rm -f $STACKFILE
fi

if [ -f $OUTPUT ] ; then
    rm -f $OUTPUT
fi

if [ -f $SITECONTENT ] ; then
    rm -f $SITECONTENT
fi

if [ -f $SORTEDSITESTACK ] ; then
    rm -f $SORTEDSITESTACK
fi

# Output
echo " "
echo " "
echo "Currently scanning $URL..."
echo " "

# Help
if [[ $# -ne 1 ]] ; then
    echo 'Usage:'
    echo './TechStack url'
    echo 'Example: ./TechStack google.com, or ./TechStack https://www.google.com'
    exit
fi

####################################################################################
# CHECK THE SITE
####################################################################################

# Get headers
curl -skLIA "Mozilla/5.0 (Windows NT 6.1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/41.0.2228.0 Safari/537.36" "$URL" -o ./output.html

curl -sLKA "Mozilla/5.0 (Windows NT 6.1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/41.0.2228.0 Safari/537.36" "$URL" >> ./output.html

###################
## WORDPRESS CHECKS
###################

# Check for wp-admin

WPADMIN="$(curl -skLKA "Mozilla/5.0 (Windows NT 6.1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/41.0.2228.0 Safari/537.36" -w "%{http_code}" "$URL/wp-admin/" -o ./sitecontent.html)" 

WPREADME="$(curl -skLA "Mozilla/5.0 (Windows NT 6.1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/41.0.2228.0 Safari/537.36" -w "%{http_code}" "$URL/readme.txt" -o ./sitecontent.html)" 

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
## JOOMLA CHECKS
###################

# Check for administrator directory 
JOOMLAADMIN="$(curl -skLA "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_10) AppleWebKit/600.1.25 (KHTML, like Gecko) Version/8.0 Safari/600.1.25" -w "%{http_code}" "$URL/administrator/" -o ./sitecontent.html)" 

# Check for status of requests 
if [ "$JOOMLAADMIN" = "200" ] ; then
    echo "[X] An admnistrator directory has been found in the root (Joomla?)."
    echo "Joomla" >> ./sitestack.txt
    echo "PHP" >> ./sitestack.txt
fi

# Check for Joomla in response 
if grep -i generator ./sitecontent.html | grep -qi joomla 
then
    echo "[X] Joomla found in headers."
    echo "Joomla" >> ./sitestack.txt
    echo "PHP" >> ./sitestack.txt

fi

###################
## APACHE CHECKS
###################

# Check for Apache in response 
if grep -i "Server:" ./output.html | grep -qi apache 
then
    echo "[X] Apache found in headers."
    echo "Apache" >> ./sitestack.txt
fi

###################
## NGINX CHECKS
###################

# Check for Nginx in response 
if grep -i "Server:" ./output.html | grep -qi nginx
then
    echo "[X] Nginx found in headers."
    echo "Nginx" >> ./sitestack.txt
fi

###################
## IIS CHECKS
###################

# Check for Nginx in response 
if grep -i "Server:" ./output.html | grep -qi IIS
then
    echo "[X] IIS found in headers."
    echo "IIS" >> ./sitestack.txt
    echo "Windows" >> ./sitestack.txt
fi

###################
## TLS CHECKS
###################

# Check for HTTPS in redirect
if grep -i "Location:" ./output.html | grep -qi https
then
    echo "[X] TLS in URL or TLS redirect found in headers."
    echo "TLS" >> ./sitestack.txt
fi

if [[ "$URL" == *"https"* ]]
then
    echo "[X] TLS found in headers."
    echo "TLS" >> ./sitestack.txt
fi

###################
## .NET CHECKS
###################

# Check for .NET in headers
if grep -i "X-Powered-By:" ./output.html | grep -qi ".NET"
then
    echo "[X] .NET found in headers."
    echo ".NET" >> ./sitestack.txt
fi

###################
## GENTOO CHECKS
###################

# Check for Gentoo in headers
if grep -i "X-Powered-By:" ./output.html | grep -qi gentoo
then
    echo "[X] Gentoo found in headers."
    echo "Gentoo" >> ./sitestack.txt
    echo "Linux" >> ./sitestack.txt
fi

###################
## DEBIAN CHECKS
###################

# Check for Debian in headers
if grep -i "X-Powered-By:" ./output.html | grep -qi dotdeb
then
    echo "[X] Debian found in headers."
    echo "Debian" >> ./sitestack.txt
    echo "Linux" >> ./sitestack.txt
fi

if grep -i "X-Powered-By:" ./output.html | grep -qi "deb*u"
then
    echo "[X] Debian found in headers."
    echo "Debian" >> ./sitestack.txt
    echo "Linux" >> ./sitestack.txt
fi

if grep -i "Server:" ./output.html | grep -qi debian
then
    echo "[X] Debian found in headers."
    echo "Debian" >> ./sitestack.txt
    echo "Linux" >> ./sitestack.txt
fi

###################
## PHP CHECKS
###################

# Check for PHP in headers
if grep -i "X-Powered-By:" ./output.html | grep -qi PHP
then
    echo "[X] PHP found in headers."
    echo "PHP" >> ./sitestack.txt
fi

###################
## FREEBSD CHECKS
###################

# Check for FreeBSD in headers
if grep -i "Server:" ./output.html | grep freebsd
then
    echo "[X] FreeBSD found in headers."
    echo "FreeBSD" >> ./sitestack.txt
fi

###################
## CLOUDFLARE CHECKS
###################

# Check for Cloudflare in headers
if grep -i "Server:" ./output.html | grep -qi cloudflare
then
    echo "[X] Cloudflare found in headers."
    echo "Cloudflare" >> ./sitestack.txt
fi

###################
## EXPRESS CHECKS
###################

# Check for in Express in headers
if grep -i "X-Powered-By:" ./output.html | grep -qi express
then
    echo "[X] Express found in headers."
    echo "Express" >> ./sitestack.txt
    echo "Node" >> ./sitestack.txt
fi

###################
## JBOSS CHECKS
###################

# Check for in JBoss in headers
if grep -i "X-Powered-By:" ./output.html | grep -qi jboss
then
    echo "[X] JBoss found in headers."
    echo "JBoss" >> ./sitestack.txt
fi

###################
## TOMCAT CHECKS
###################

# Check for in Tomcat in headers
if grep -i "X-Powered-By:" ./output.html | grep -qi tomcat
then
    echo "[X] Tomcat found in headers."
    echo "Tomcat" >> ./sitestack.txt
fi

###################
## GITHUB Checks
###################

# Check for in Github in headers
if grep -i "Server:" ./output.html | grep -qi github
then
    echo "[X] Github found in headers."
    echo "Github" >> ./sitestack.txt
fi

###################
## GSE Checks
###################

# Check for in GSE in headers
if grep -i "Server:" ./output.html | grep -qi gse
then
    echo "[X] GSEfound in headers."
    echo "GSE" >> ./sitestack.txt
fi

###################
## AMAZONS3 Checks
###################

# Check for in AmazonS3 in headers
if grep -i "Server:" ./output.html | grep -qi amazons3
then
    echo "[X] Amazon S3 found in headers."
    echo "AmazonS3" >> ./sitestack.txt
fi

###################
## BAIDU Checks
###################

# Check for in Baidu in headers
if grep -i "Server:" ./output.html | grep -qi bws
then
    echo "[X] Amazon S3 found in headers."
    echo "BWS" >> ./sitestack.txt
fi

###################
## ATS Checks
###################

# Check for in ATS in headers
if grep -i "Server:" ./output.html | grep -qi ats
then
    echo "[X] Apache ATS found in headers."
    echo "ATS" >> ./sitestack.txt
fi

###################
## SQUID Checks
###################

# Check for in ATS in headers
if grep -i "Server:" ./output.html | grep -qi squid
then
    echo "[X] Squid found in headers."
    echo "Squid" >> ./sitestack.txt
fi

###################
## WEIBO Checks
###################

# Check for in Weibo in headers
if grep -i "Server:" ./output.html | grep -qi weibo
then
    echo "[X] Weibo found in headers."
    echo "Weibo" >> ./sitestack.txt
fi

###################
## GWS Checks
###################

# Check for in GWS in headers
if grep -i "Server:" ./output.html | grep -qi gws
then
    echo "[X] GWS found in headers."
    echo "GWS" >> ./sitestack.txt
fi

###################
## UBUNTU Checks
###################

# Check for in Ubuntu in headers
if grep -i "X-Powered-By:" ./output.html | grep -qi ubuntu
then
    echo "[X] Ubuntu found in headers."
    echo "Ubuntu" >> ./sitestack.txt
    echo "Linux" >> ./sitestack.txt
fi

###################
## PHP Checks
###################

# Check for in PHP in headers
if grep -i "X-Powered-By:" ./output.html | grep -qi php
then
    echo "[X] PHP found in headers."
    echo "PHP" >> ./sitestack.txt
fi

###################
## EXPRESS Checks
###################

# Check for in Express in headers
if grep -i "X-Powered-By:" ./output.html | grep -qi express
then
    echo "[X] Express found in headers."
    echo "Express" >> ./sitestack.txt
fi

###################
## HHVM Checks
###################

# Check for in HHVM in headers
if grep -i "X-Powered-By:" ./output.html | grep -qi hhvm
then
    echo "[X] HHVM found in headers."
    echo "HHVM" >> ./sitestack.txt
fi

###################
## W3 TOTAL CACHE CHECKS
###################

# Check for in W3 Total Cache in headers
if grep -i "X-Powered-By:" ./output.html | grep -qi "w3 total cache"
then
    echo "[X] W3 Total Cache found in headers."
    echo "W3TotalCache" >> ./sitestack.txt
    echo "Wordpress" >> ./sitestack.txt
fi

###################
## TOMCAT CHECKS
###################

# Check for in Tomcat in headers
if grep -i "Server:" ./output.html | grep -qi tomcat
then
    echo "[X] Tomcat found in headers."
    echo "Tomcat" >> ./sitestack.txt
    echo "Apache" >> ./sitestack.txt
fi

###################
## SUSE CHECKS
###################

# Check for Suse in headers
if grep -i "Server:" ./output.html | grep -qi suse
then
    echo "[X] Tomcat found in headers."
    echo "Tomcat" >> ./sitestack.txt
    echo "Apache" >> ./sitestack.txt
fi

###################
## CENTOS CHECKS
###################

# Check for CentOS in headers
if grep -i "Server:" ./output.html | grep -qi centos
then
    echo "[X] CentOS found in headers."
    echo "CentOS" >> ./sitestack.txt
    echo "Linux" >> ./sitestack.txt
fi

###################
## REDHAT CHECKS
###################

# Check for Red Hat in headers
if grep -i "Server:" ./output.html | grep -qi "red hat"
then
    echo "[X] Red Hat found in headers."
    echo "Redhat" >> ./sitestack.txt
    echo "Linux" >> ./sitestack.txt
fi

###################
## UNIX CHECKS
###################

# Check for Unix in headers
if grep -i "Server:" ./output.html | grep -qi unix
then
    echo "[X] Unix found in headers."
    echo "Unix" >> ./sitestack.txt
fi

###################
## ORACLE CHECKS
###################

# Check for Oracle in headers
if grep -i "Server:" ./output.html | grep -qi oracle
then
    echo "[X] Oracle App Server found in headers."
    echo "OracleAppServer" >> ./sitestack.txt
fi

###################
## SUCURI CHECKS
###################

# Check for Sucuri in headers
if grep -i "Server:" ./output.html | grep -qi sucuri
then
    echo "[X] Sucuri found in headers."
    echo "Sucuri" >> ./sitestack.txt
fi

###################
## VARNISH CHECKS
###################

# Check for Varnish in headers
if grep -i "Server:" ./output.html | grep -qi varnish
then
    echo "[X] Varnish found in headers."
    echo "Varnish" >> ./sitestack.txt
fi

###################
## LIGHTHTTPD CHECKS
###################

# Check for Light HTTPD in headers
if grep -i "Server:" ./output.html | grep -qi lighttpd
then
    echo "[X] Light HTTPD found in headers."
    echo "LightHTTPD" >> ./sitestack.txt
fi

###################
## SUN CHECKS
###################

# Check for Sun in headers
if grep -i "Server:" ./output.html | grep -qi sun
then
    echo "[X] Sun found in headers."
    echo "Sun" >> ./sitestack.txt
    echo "Unix" >> ./sitestack.txt
fi

#####################################################################################
# OUTPUT
#####################################################################################

########################
# CLEANUP
########################

if [ -f $STACKFILE ] ; then
    sort ./sitestack.txt > ./sortedsitestack.txt
    uniq ./sortedsitestack.txt > ./sitestack.txt
fi

if [ -f $STACKFILE ] ; then
    echo " "
    cat art.txt
    echo " "
    echo "The site APPEARS to be running..."
    echo " "
    echo "--"
    cat ./sitestack.txt
    echo "--"
    echo " "
    echo "NOTE: It's easy to fool this kind of magic."
else
    echo " "
    echo "No technologies were detected on this site."
    echo " "
fi

# Cleanup
if [ -f $STACKFILE ] ; then
    rm -f $STACKFILE
fi

if [ -f $OUTPUT ] ; then
    rm -f $OUTPUT
fi

if [ -f $SITECONTENT ] ; then
    rm -f $SITECONTENT
fi

if [ -f $SORTEDSITESTACK ] ; then
    rm -f $SORTEDSITESTACK
fi
