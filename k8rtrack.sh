#!/bin/bash
function log (){
	echo -e "[$(date +"%D %T")]: \n${*}"
}
function usage(){
 echo "Usage: ${0} [resource type] [namespace] [resouce name]
 export POLLINTERVAL=x rtrack.sh ... to set seconds bewteen kubectl polls of the resource [default: 2]"
}
[[ $# -eq 0 ]] && usage && exit 1;
rtype="${1:?"Expected resource type as first parameter"}"
rns="${2:?"Expected namespace as second parameter"}"
rname="${3:?"Expected resouce name as third parameter"}"
kcommand="kubectl get ${rtype} -n ${rns} ${rname} -oyaml"
while :; do
  curryaml="$($kcommand)"
  [[ $lastyaml == "" ]] && lastyaml="${curryaml}"
  if ! lastdiff="$(diff --side-by-side --suppress-common-lines <(echo "${lastyaml}") <(echo "${curryaml}"))"; then log "${lastdiff}"; fi  
  lastyaml="${curryaml}"
  sleep "${POLLINTERVAL:-2}"
done
