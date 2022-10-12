#!/bin/bash

  TMPDIR="/tmp"
  NONINTERACTIVE=`echo $* | grep -- "-q" | wc -l` # QUIET
# ----
  if [ "$NONINTERACTIVE" != 1 ];then
     echo -e ":NN:\e[31mTHE FOLLOWING PROCESS WILL DOWNLOAD AND :NN:INSTALL
              FONT FILES FROM REMOTE SOURCES :NN: AND MAY OVERWRITE 
              EXISTING CONFIGURATIONS.\e[0m:NN:" | #
     sed ':a;N;$!ba;s/\n//g' | tr -s ' '    | #
     sed 's/:NN:/\n/g' | sed 's/^[ ]*//'
     read -p "I KNOW WHAT I'M DOING? [y/n] " ANSWER
     if [ "$ANSWER" != "y" ];then echo -e "\nCIAO.\n";exit 0;else echo;fi
  fi
# ----
  if   [ `echo $* | sed 's/ /\n/g' | #
          egrep -- "^--tex|^--ttf" | #
          wc -l` -lt 1 ];then 
  echo -e "\e[31mfontinstall.sh CURRENTLY SUPPORTS --tex OR --ttf\e[0m" 
  echo -e "\e[31mUSAGE:\e[0m ./fontinstall --tex  \
   https://fontain.org/iaduospace/export/tex/ia-writer-duospace.tex.zip \
  :NI: ./fontinstall --ttf \
   https://fontain.org/plexmono/export/ttf/ibm-plex-mono.ttf.zip" | #
  tr -s ' ' | sed 's/:NI:/\n      /g'

  exit 0
  fi
# ----
  REMOTESRC=`echo $* | sed 's/ /\n/g' | grep -v -- "^-" | tail -n 1`
  if [ -f $REMOTESRC ] 
  then REMOTEGET="$TMPDIR/"`basename $REMOTESRC`
       cp $REMOTESRC $REMOTEGET
  elif [ "$REMOTESRC" != "" ]
  then REMOTEGET="$TMPDIR/"`basename $REMOTESRC`
       wget -q $REMOTESRC -O $REMOTEGET
  else exit 0;
  fi
# --------------------------------------------------------------------------- #
  if   [ `echo $* | sed 's/ /\n/g' | grep -- "^--tex" | wc -l` -gt 0 ]
  then    MODUS="TEX"
          if [ -f $REMOTEGET ]
          then mv $REMOTEGET $TMPDIR/tmp.zip
          else echo "SOMETHING WENT WRONG";exit 0;
          fi
  elif [ `echo $* | sed 's/ /\n/g' | grep -- "^--ttf" | wc -l` -gt 0 ]
  then    MODUS="TTF"
          if [ -f $REMOTEGET ]
          then sleep 0
          else echo "SOMETHING WENT WRONG";exit 0;
          fi
  else    echo "DON'T KNOW WHAT TO DO?"
          exit 0;
  fi
 # -------------------------------------------------------------------- #
   if [ "$MODUS" == TEX ] # ========================================= #
   then # ----------------------------------------------------------- #
        # UNZIP AND MOVE TO TEXMFHOME
        # ----------------------------------------------------------- #
          TEXMFHOME=`kpsewhich --var-value=TEXMFHOME`
          if [ ! -d "$TEXMFHOME" ];then
               echo "NO TEXMFHOME DIR"
               cd /etc/texmf/texmf.d
               touch 00_texmfhome.cnf
               echo "TEXMFHOME = ~/.TEXMF" > 00_texmfhome.cnf
               mkdir ~/.TEXMF
               update-texmf
               TEXMFHOME=`kpsexpand \\$TEXMFHOME`
               cd -
          fi
        # --
          if [ -f $TMPDIR/tmp.zip ];then
               unzip -qo -u -C $TMPDIR/tmp.zip "*.zip" -d $TMPDIR
               unzip -qo -u -C $TMPDIR/*.zip "TEXMF/*" -d $TMPDIR
               rm $TMPDIR/tmp.zip
               rsync -a ${TMPDIR}/TEXMF/ $TEXMFHOME
               if [ -d "${TMPDIR}/TEXMF" ]
               then rm -rf ${TMPDIR}/TEXMF ; rm $TMPDIR/*.zip
               fi
          fi
        # ----------------------------------------------------------- #
        # UPDATE TEX INSTALLATION
        # ----------------------------------------------------------- #
          UPDMAP="$TEXMFHOME/web2c/updmap.cfg"
          for MAP in `find $TEXMFHOME -name "*.map" | #
                      rev | cut -d "/" -f 1 | rev | sort -u`
           do echo "Map $MAP" >> $UPDMAP
          done
        # ----------------------------------------------------------- #
          sort -u -o $UPDMAP $UPDMAP
        # ----------------------------------------------------------- #
          updmap-user # https://tex.stackexchange.com/q/255709
        # ----------------------------------------------------------- #
   fi # ============================================================= #
 
 # -------------------------------------------------------------------- #
   if [ "$MODUS" == TTF ] # ========================================= #
   then   mkdir -p ~/.fonts/fontinstall
        # ----------------------------------------------------------- #
          ISZIP=`echo $REMOTEGET | grep ".zip$" | wc -l`
          if [ "$ISZIP" == 1 ]
          then unzip -qo $REMOTEGET -d ~/.fonts/fontinstall
          else cp $REMOTEGET ~/.fonts/fontinstall
          fi
        # ----------------------------------------------------------- #
          rm $REMOTEGET
   fi # ============================================================= #
 # -------------------------------------------------------------------- #

exit 0;
