#!/bin/bash


function vmExists () {
	local vmName='"'$1'"'
	local itemVmName
	local output

	aVmList=$(vboxmanage list vms |awk '{print$1 "+" $2}')

	for item in $aVmList; do
		itemVmName=$(echo $item|awk -F+ '{print$1}')
		
			if [ "$vmName" == "$itemVmName" ]; then
		        	#echo "0"
				return 0 #True
				exit
			 fi
	done
	#echo "1"
	return 1 #False
	
}

#------------------------------------------------#
function vmState() {
        local vmName=$1
	local state

	if ! vmExists $vmName; then return 1; fi

        state=$(vboxmanage showvminfo $vmName |grep State |awk '{ print $1" "$2" "$3}')
        state=$(echo $state|cut -d'(' -f1 |awk -F':' '{print$2}')

        echo $state
}

#--------------------------------

function vmMount () {
	local vmName=$1
	local output
	
	if ! vmExists $vmName; then return 1; fi


	output=$(vboxmanage showvminfo $vmName |grep "Config " |awk -F':' '{print$2}')
	output=${output%/*vbox}

	echo $output
}
#------------------------------------------------#

function vmPort () {
        local vmName=$1
        local output

        if ! vmExists $vmName; then return 1; fi
	
	output=$(VBoxManage showvminfo $vmName |grep 'Ports ' |awk '{print $6}' |cut -d',' -f1)
	
	echo $output
}
#-----------------------------------------------------#
function vmNetwork () {
        local vmName=$1
        local output

        if ! vmExists $vmName; then return 1; fi

	output=$(VBoxManage showvminfo $vmName |grep NIC |awk -F':' '{print$1 $4 $5}' |grep Cable |awk -F',' '{print$1 $2}')
	
	echo -e $output
}

#---------------------------------------------------------------
function drbdResource () {
	local vmName=$1
	local output
	
	if ! vmExists $vmName; then return 1; fi	

	output=$(vboxmanage showvminfo $vmName |grep "Config " |awk -F':' '{print$2}'|awk -F '/' '{print$3}')
	output=$(mount |grep "$output" |awk -F'on' '{print$1}' |grep /dev/)

	echo $output
}
