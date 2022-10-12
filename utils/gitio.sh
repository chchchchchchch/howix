#!/bin/bash

# WRAPPER FOR GITHUB URL SHORTENER
# https://blog.github.com/2011-11-10-git-io-github-url-shortener/

   LONGURL="$1";SHORTURLBASE="https://git.io"
 # -------------------------------------------------------------------------- #
 # CHECK INPUT
 # -------------------------------------------------------------------------- #
   if [ "$LONGURL" != "" ];then
   URLSTATUS=`curl -s -o /dev/null -IL -w "%{http_code}" $LONGURL`
   if [ "$URLSTATUS" != "200" ]
    then echo "----"; echo "PLEASE PROVIDE A VALID GITHUB URL"
         exit 0;
   fi
   else  echo "----"; echo "PLEASE PROVIDE URL"
         exit 0;
   fi 
 # -------------------------------------------------------------------------- #
 # CREATE SHORTURL
 # -------------------------------------------------------------------------- # 
   GITHASH=`echo $LONGURL  | sed 's,/,\n,g' | #
            grep '^[0-9a-f]\+$' | head -n 1 | #
            cut -c 1-7` #
   BASENAME=`basename $LONGURL | sed 's/\.[a-z]\+$//'`
   EXTENSION=`basename $LONGURL | sed "s,${BASENAME},,"` 
 
   SHORTNAME="${BASENAME}.${GITHASH}${EXTENSION}"
 # -------------------------------------------------------------------------- # 
 # SHOW USER SHORTURL
 # -------------------------------------------------------------------------- # 
   echo -e "\n----\n \
            SHORTEN URL:\n
            \e[31m$LONGURL\e[0m \n-> \
            \e[32m$SHORTURLBASE/$SHORTNAME \e[0m\n" | #
            tr -s ' ' | sed 's/^[ ]*//'
   read -p "SHOULD WE DO IT? [y/n] " ANSWER
   if [ X$ANSWER != Xy ] ; then echo "BYE."; exit 1;
                           else echo; fi
 # -------------------------------------------------------------------------- # 
 # CREATE SHORT URL
 # -------------------------------------------------------------------------- # 
   SHORTURL=`curl -i https://git.io -s \
                  -F "url=$LONGURL" -F "code=$SHORTNAME" | #
                  grep "^Location:" | cut -d ":" -f 2- | #
                  sed 's/^[ ]*//'`
   if [ "$SHORTURL" != "" ];then
       
         # DISPLAY IF SUCCESSFUL
         # ---------------------
           echo -e "\n$SHORTURL\n"
   else
         # REPEAT REQUEST FOR DETAILED OUTPUT
         # ----------------------------------
           curl -i https://git.io -s -F "url=$LONGURL" -F "code=$SHORTNAME"
   fi
 # -------------------------------------------------------------------------- # 

exit 0;

