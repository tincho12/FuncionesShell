#!/bin/bash


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

        if ! vmExists $vmId; then return 1; fi

        name=$(vboxmanage showvminfo $vmId |grep Name: |awk '{ print $2}')

       echo $name
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
