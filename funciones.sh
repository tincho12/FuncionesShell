#!/bin/bash

#-----------------------
#Declaracion de Constantes
blue="\E[34m\E[1m";
red="\E[31m\E[1m";
yellow="\E[33m\E[1m";
green="\E[37m\E[32m\E[1m";
normal="\E[m";
purple="\033[1;35m";
cyan="\E[1;36m\E[1m";
gray="\033[1;30m";
#-------------------------

# -----------------------------------------------------
# Retorna una lista con los identificadores de vms registradas accessibles
# -----------------------------------------------------
function vmRegisteredList () {
        echo $(vboxmanage list vms |awk -F'" ' '{print$2}')
}

# -----------------------------------------------------
# Retorna una lista con los nombres de vms registradas accessibles
# -----------------------------------------------------
function vmListName () {
	echo $(vboxmanage list vms  |grep -v "<inaccessible>" |awk '{print$1}')
}

# -----------------------------------------------------
# Retorna una lista con los identificadores de vms registradas accessibles
# -----------------------------------------------------
function vmListId () {
        echo $(vboxmanage list vms |grep -v "<inaccessible>" |awk -F'" ' '{print$2}')
}

# -------------------------------------------------------------------------
# Retorna 0 si el nombre de la maquina virtual se encuentra registrada y Accesible
#         1 en caso contrario. "0 Es True en Shell Script"
# ------------------------------------------------------------------------
function vmExists () {
	local vmId=$1

	for itemVmId in $(vmListId); do
		if [ $vmId == $itemVmId ]; then
			return 0 #True
			exit
		 fi
	done
	
	return 1 #False
}

#------------------------------------------------#
# Retorna el estado de la maquina virtual si se encuentra registrada y Accesible
# Codigo 1 en caso contrario indicando error
#------------------------------------------------#
function vmState() {
        local vmId=$1
	local state

	if ! vmExists $vmId; then return 1; fi

        state=$(vboxmanage showvminfo $vmId |grep State |awk '{ print $1" "$2" "$3}')
        state=$(echo $state|cut -d'(' -f1 |awk -F':' '{print$2}')

        echo $state
}


#--------------------------------
# Retorna el punto de montaje de la maquina virtual si se encuentra registrada
# Codigo 1 en caso contrario indicando error
#----------------------------------
function vmMount () {
	local vmId=$1
	local output
	
	if ! vmExists $vmId; then return 1; fi


	output=$(vboxmanage showvminfo $vmId |grep "Config " |awk -F':' '{print$2}')
	output=${output%/*vbox}

	echo $output
}
#------------------------------------------------#
# Retorna el Puerto de la maquina virtual si se encuentra registrada
# Codigo 1 en caso contrario indicando error

function vmPort () {
        local vmId=$1
        local output

        if ! vmExists $vmId; then return 1; fi
	
	output=$(VBoxManage showvminfo $vmId |grep 'Ports ' |awk '{print $6}' |cut -d',' -f1)
	
	echo $output
}

#--------------------------------------------------------------------
# Retorna el nombre de la maquina virtual si se encuentra registrada
# Codigo 1 en caso contrario indicando error
#-------------------------------------------------------------------

function vmName() {
        local vmId=$1
        local name

        if ! [[ "$(vmRegisteredList)" == *"$vmId"* ]] ; then return 1; fi

        name=$(vboxmanage list vms |grep $vmId |awk -F'{' '{ print $1}')

	
       echo $name
}

#--------------------------------------------------------------------
# Imprime estado de las vms
#-------------------------------------------------------------------

function vmStatus() {
		aListStatus=$1		
                aVmList=$(vmRegisteredList)
                for vmId in $aVmList
                do

                	name=$(vmName $vmId)
                        mount=$(vmMount $vmId)
                        state=$(vmState $vmId)
                        drbd=$(drbdResource $vmId)
                        port=$(vmPort $vmId)
			port=$port
			maybeVmId=""

			if ! vmExists $vmId; then maybeVmId=$vmId; fi	

			tmp=$(echo $name '|' $state '|' $port '|' $drbd '|' $mount '|' $maybeVmId)
			if [ "$aListStatus" != "" ]; then
	                        echo $tmp | grep -e $(echo $aListStatus |sed 's/ / -e /g') | awk -F'|' '{ printf "\033[1;30m%20s \033[1;35m%-17s \033[1;30m%5d\n", $1, $2, $3}'
			else
				echo $tmp | awk -F'|' '{ printf "\033[1;30m%-20s \033[1;35m%-17s \033[1;30m%5d \033[1;34m%-15s \033[1;33m%-s \033[1;31m%s \n", $1,$2, $3, $4, $5, $6}'
			fi

                done
}


#---------------------------------------------------------------
function drbdResource () {
	local vmId=$1
	local output
	
	if ! vmExists $vmId; then return 1; fi	

	output=$(vboxmanage showvminfo $vmId |grep "Config " |awk -F':' '{print$2}'|awk -F '/' '{print$3}')
	output=$(mount |grep "$output" |awk -F'on' '{print$1}' |grep /dev/)

	echo $output
}
