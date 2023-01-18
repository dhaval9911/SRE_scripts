#!/bin/bash


month=$(date +%B)
date=$(date +%d | sed 's/^0*//' )
year=$(date +%Y)

function ordinal () {
  case "$date" in
    *1[0-9] | *[04-9]) echo "$date"th;;
    *1) echo "$date"st;;
    *2) echo "$date"nd;;
    *3) echo "$date"rd;;
  esac
}

date=$(ordinal $x)



#month=$(date +%B)
#date=$(date +%d)
#year=$(date +%Y)
# echo $date $month $year
 open -a "Google Chrome" "https://splunk.atlassian.net/wiki/search?text=$date%20$month%20$year&lastModified=lastDay&spaces=CLOUDOPS&type=page&title=true"
