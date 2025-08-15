# Press l to select a file
function lfp(){
  local TEMP=$(mktemp)
  lf -selection-path=$TEMP
  cat $TEMP
}

lfp
