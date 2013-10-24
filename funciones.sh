#!/bin/bash

# Retorna 0 si el nombre de la maquina virtual se encuentra registrado
# o 	  1 en caso contrario

function vmExists () {
	local vmName='"'$1'"'
	local itemVmName
	local output

	aVmList=$(vboxmanage list vms |awk '{print$1 "+" $2}' |grep -v "<inaccessible>")

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
# Retorna el estado de la maquina virtual si se encuentra registrada
# Codigo 1 en caso contrario indicando error

function vmState() {
        local vmName=$1
	local state

	if ! vmExists $vmName; then return 1; fi

        state=$(vboxmanage showvminfo $vmName |grep State |awk '{ print $1" "$2" "$3}')
        state=$(echo $state|cut -d'(' -f1 |awk -F':' '{print$2}')

        echo $state
}

#--------------------------------
# Retorna el punto de montaje de la maquina virtual si se encuentra registrada
# Codigo 1 en caso contrario indicando error

function vmMount () {
	local vmName=$1
	local output
	
	if ! vmExists $vmName; then return 1; fi


	output=$(vboxmanage showvminfo $vmName |grep "Config " |awk -F':' '{print$2}')
	output=${output%/*vbox}

	echo $output
}
#------------------------------------------------#
# Retorna el Puerto de la maquina virtual si se encuentra registrada
# Codigo 1 en caso contrario indicando error

function vmPort () {
        local vmName=$1
        local output

        if ! vmExists $vmName; then return 1; fi
	
	output=$(VBoxManage showvminfo $vmName |grep 'Ports ' |awk '{print $6}' |cut -d',' -f1)
	
	echo $output
}
#-----------------------------------------------------#
# Retorna las interfaces de red la maquina virtual si se encuentra registrada
# Codigo 1 en caso contrario indicando error

function vmNetwork () {
        local vmName=$1
        local output

        if ! vmExists $vmName; then return 1; fi

	output=$(VBoxManage showvminfo $vmName |grep NIC |awk -F':' '{print$1 $4 $5}' |grep Cable |awk -F',' '{print$1 $2}')
	
	echo -e $output
}

#-----------------------------------------------------#
# Retorna la cantidad de interfaces de red de la maquina virtual 
# Codigo 1 en caso contrario indicando error

function vmNetCount () {
        local vmName=$1
        local output

        if ! vmExists $vmName; then return 1; fi
	

        output=$(VBoxManage showvminfo $vmName |grep NIC |awk -F':' '{print$1 $4 $5}' |grep Cable |awk -F',' '{print$1 $2}'  |grep -c "NIC")

        echo -e $output
}
#----------------------------------------------------
# Retorna la cantidad de interfaces de red de la maquina virtual 
# Codigo 1 en caso contrario indicando error

function vmNetState () {
        local vmName=$1
	local nicNumber=$2
        local output

        if ! vmExists $vmName; then return 1; fi


        output=$(VBoxManage showvminfo Debian8 |grep NIC |awk -F':' '{print$1 $4 $5}' |grep Cable |awk -F',' '{print$1 $2}' |grep "NIC $nicNumber" |awk -F' ' '{print$3}')

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
