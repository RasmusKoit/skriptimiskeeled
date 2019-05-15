#!/bin/bash 

if [ -z "$1" ]; then
	echo "No argument supplied"
   	echo "Please specify path to search from"
    	echo "for example: ./symlinks.sh /etc/nginx"
else
	find "$1" ! -readable -prune -o -type l -ls -print | grep " -> " | awk '{print $11 " " $12 " " $13}' > foundLinks.txt
	echo "Search complete, results are in ./foundLinks.txt"
fi

