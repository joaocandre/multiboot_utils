#! /bin/bash

# specific to systemd-boot, only for readibility
NAMESPACE=4a67b082-0a4c-41cf-b6c7-440b29bb8c4f

# function that converts decimal, null-terminated sequence into entry string
function get_name () {
	if ! [[ -n "$2" ]]; then
		OUT=()
	else
		local -n OUT=$2
	fi
	IFS=' ' read -ra CH <<< "$1"
	local PREV=' '
	for i in "${CH[@]}"; do
		if [[ "$i" != 0 ]]; then
			local CHA=`printf "\x$(printf %x $i)"`
			local NAME="${NAME}${CHA}"
		fi
		if [[ $i == ${PREV} ]]; then
			if ! [[ -z ${NAME} ]]; then
				# echo ${NAME}
		    	OUT+=(${NAME})
		    	NAME=""
		    fi
	    fi
	    PREV=$i
	done
	# echo ${OUT[@]}
}

# id current entry
# echo "Current boot entry: "
ENTRY_SELECTED=`efivar --name ${NAMESPACE}-LoaderEntrySelected --print-decimal` # --export=.efivar
get_name "${ENTRY_SELECTED}" "CURRENT"
# echo ${CURRENT}

# get all available entries
ENTRIES=`efivar --name ${NAMESPACE}-LoaderEntries --print-decimal` # --export=.efivar
get_name "${ENTRIES}" "NAMES"

# select/parse next boot entry
if [[ "$#" == "0" ]]; then
	# interactive
	echo "Available boot entries (* current): "
	for (( i = 0; i < ${#NAMES[@]}; i++ )); do
		if [[ "${CURRENT}" == "${NAMES[i]}" ]]; then
			CURRENT_ID="$((i + 1))"
			echo "$((i + 1))) ${NAMES[i]} (*)"
		else
			echo "$((i + 1))) ${NAMES[i]}"
		fi
	done
	# prompt user to select next boot
	NEXT_ID=0
	while [[ ${NEXT_ID} == 0 ]]; do
		read -p "Select next boot [1-${#NAMES[@]}]: " NEXT_ID
		if [[ ${NEXT_ID} > ${#NAMES[@]} ]]; then
			# echo "Invalid selection!"
			NEXT_ID=0
		fi
	done
	NEXT=${NAMES[$((NEXT_ID - 1))]}
	read -p "Confirm '${NEXT}' as next boot, continue? (Y/n): " confirm && [[ $confirm == '' || $confirm == [yY] || $confirm == [yY][eE][sS] ]] || exit 1
else
	NEXT=$1
	NEXT_ID=0
	# search for matching entry
	for (( i = 0; i < ${#NAMES[@]}; i++ )); do
		if [[ ("${NEXT}" == "${NAMES[i]}") || ("auto-${NEXT}" == "${NAMES[i]}") ]]; then
			NEXT_ID="$((i + 1))"
			NEXT="${NAMES[i]}"
		fi
	done
	if [[ "${NEXT_ID}" == "0" ]]; then
		echo "Invalid/unavailable boot entry '${NEXT}'"
		exit 1
	fi
fi

# null-terminate all characters
NEXT_NT=""
for (( i=0; i<${#NEXT}; i++ )); do
  NEXT_NT="${NEXT_NT}${NEXT:$i:1}\0"
done

# set/update EFI variables
TARGET_EFI_VAR="LoaderEntryOneShot"  # "LoaderEntryDefault" for persistent/default change
TMP_FILE=.temp
printf "${NEXT_NT}\0\0" > ${TMP_FILE}
sudo efivar --name ${NAMESPACE}-${TARGET_EFI_VAR} --write --datafile ${TMP_FILE}
rm -rf ${TMP_FILE}
# debug result
efivar --name ${NAMESPACE}-${TARGET_EFI_VAR}

# disable boot menu
TARGET_EFI_VAR="LoaderConfigTimeoutOneShot"
printf "0\0\0" > ${TMP_FILE}
sudo efivar --name ${NAMESPACE}-${TARGET_EFI_VAR} --write --datafile ${TMP_FILE}
rm -rf ${TMP_FILE}
# debug result
efivar --name ${NAMESPACE}-${TARGET_EFI_VAR}
