#!/usr/bin/bash

SS_FOLDER="${HOME}/screenshot"
SS_PREF="${SS_FOLDER}/scr"
SS_EXP=".png"

ls "${SS_PREF}"* 2> /dev/null 					\
  | sed 's#^'"${SS_PREF}"'##'                                   \
  | sed 's#'"${SS_EXP}"'$##'                                    \
  | sort -V                                                     \
  | tail -n 1                                                   \
  | sed 's#$#+1#'                                               \
  | bc                                                          \
  | sed 's#.*#import -window root '"${SS_PREF}&${SS_EXP}#"	\
  | /usr/bin/bash

