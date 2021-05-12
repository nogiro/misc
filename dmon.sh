XRANDR='/usr/bin/xrandr'

MAIN_MON="eDP1"
TGT="DP1"
FLAG=""
M_RES=""

TGT="`$XRANDR | grep '\<connected\>' | cut -d' ' -f1 | grep -v "${MAIN_MON}" | head -n 1`"

function put_err {
  case $1 in
   "arg")
      cat 1>&2 <<-EOF 
	$0: error: invalied args
	$0: usage: $0 [right|left|above|below|mirror|off|on]
	EOF
    ;;
    "noTGT")
      cat 1>&2 <<-EOF 
	$0: error: external monitor not found
	EOF
    ;;
    *)
      cat 1>&2 <<-EOF 
	$0: error: undefined error
	EOF
    ;;
  esac
}

if [ -z "$TGT" -a ! "$1" = "off" ];then
  put_err noTGT
  exit 1
fi

if [ "$1" = "right" ];then
  MODE_POS="--right-of"
elif [ "$1" = "above" ];then
  MODE_POS="--above"
elif [ "$1" = "below" ];then
  MODE_POS="--below"
elif [ "$1" = "left" ];then
  MODE_POS="--left-of"
elif [ "$1" = "mirror" ];then
  MODE_POS="--same-as"
elif [ "$1" = "off" ];then
  xrandr | sed -n '/^[^[:space:]].*connected.*/s/^\([^[:space:]]*\)[[:space:]].*/\1/p' | grep -v '^'"${MAIN_MON}"'$' |\
  while read TGT; do
    ${XRANDR} --output ${TGT} --off
  done
  kill `pgrep trayer` `pgrep conky`
  exit 0
elif [ "$1" = "on" ];then
  $0 right # default
  exit $?
else
  put_err arg
  exit 1
fi

${XRANDR} | \
while read LINE; do

  if [ "${FLAG}" = "${MAIN_MON}" ] && [ -z "${M_RES}" ]; then
     M_RES="`echo ${LINE} | awk '{print $1}'`"
   FLAG=""
  elif [ "${FLAG}" = "${TGT}" ]; then
   if [ -z "$2" ] || [ -z "`xrandr | sed -n '/^HDMI1/,/^[^[:space:]]/p' | grep '\<'"$2"'\>'`" ]; then
     RES="`echo ${LINE} | awk '{print $1}'`"
   else
     RES="$2"
   fi
   ${XRANDR} --output "${MAIN_MON}" --mode "${M_RES}" --output "${TGT}" --mode "${RES}" "${MODE_POS}" "${MAIN_MON}"
   exit 0
  elif [ "`echo ${LINE} | grep ^${TGT}`" ]; then
    if [ "`echo ${LINE} | grep 'disconnected'`" ]; then
      put_err noTGT
      exit 1
    fi
    FLAG=${TGT}
  elif [ "`echo ${LINE} | grep ^${MAIN_MON}`" ]; then
    FLAG=${MAIN_MON}
  fi
done

kill `pgrep trayer` `pgrep conky`

