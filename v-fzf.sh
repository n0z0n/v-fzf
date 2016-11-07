#!/usr/bin/env bash

ECHO=/usr/local/opt/coreutils/libexec/gnubin/echo
function v() {
	vagrant_command=${1:-"status"}
	fzf_option=${2:-}
	machine_index=$(cat ~/.vagrant.d/data/machine-index/index)
	idlist="$(${ECHO} "${machine_index}" | jq ".machines | keys" | jq -r ".[]")"

	infos=""
	for id in $(${ECHO} "${idlist}")
	do
		line=$(${ECHO} "${machine_index}" | jq -r "[.machines[\"${id}\"] | .name, .state, .vagrantfile_path] | @csv")
		infos="${id},${line}\n${infos}"
	done

	output=$( (${ECHO} "id,name,state,path"; ${ECHO} -e "${infos}" | sed -e 's:"::g'| tail -n +1) | column -t -s , | fzf-tmux ${fzf_option} --header-lines=1)

	ret=$?
	if [[ $ret -eq 0 ]]; then
 		while read -r line
 		do
 	 		vagrantfile_path=$( ${ECHO} "${line}" | awk '{print $4}' )
 			id=$( ${ECHO} "${line}" | awk '{print $1}' )
			(cd "${vagrantfile_path}" && vagrant "${vagrant_command}" "${id}")
		done <<- END
			${output}
		END
	fi
}

function vm() {
	v "${1}" --multi
}

