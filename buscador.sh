#!/bin/bash

#Colors
green="\e[0:32m\033[1m"
red="\e[0:31m\033[1m"



function ctrl_c(){
    echo -e "${red}\n\n [+] Saliendo...${end}\n"
    tput cnorm && exit 1
}

trap ctrl_c INT

#Variables Globales
main_url="https://htbmachines.github.io/bundle.js"

function helpPanel(){
    echo -e "\n${green}[+] Uso:${end}"
    echo -e "\t${green}u) Descargar o actulizar archivos${end}"
    echo -e "\t${grenn}i) Busqueda por dirección IP${end}"
    echo -e "\t${green}m) Buscar por nombre de maquina${end}"
    echo -e "\t${green}y) Link de YouTube maquina ${end}"
    echo -e "\t${green}d) Buscar por dificultad ${end}"
    echo -e "\t${green}o) Buscar por sistema Operativo${end}"
    echo -e "\t${green}h) Mostrar panel de ayuda${end}"
}


function updateFiles(){
    if [ ! -f bundle.js ]; then
	tput civis
	echo -e "\n${green}[!]Descargando archivos...${end}\n"
	curl -s $main_url > bundle.js
	echo -e "\n${green}[+]Todos los archivos han sido descargados exitosamente${end}\n"
	tput cnorm
    else
	tput civis
	curl -s $main_url > bundle_temp.js
	md5sum_temp_value=$(md5sum bundle_temp.js | awk '{print $1}')
	md5sum_origin_value=$(md5sum bundle.js | awk '{print $1}')
	
	if [ "$md5sum_temp_value" == "$md5sum_origin_value" ]; then
	  echo "[+]No hay actualizaciones"
	  rm bundle_temp.js 
	else
	  echo "[+]Hay actualizaciones"
	  rm bundle.js && mv bundle_temp.js bundle.js
	fi
	tput cnorm
    fi
}

function searchMachine(){
    machineName="$1"
    machineNameCheck="$(cat bundle.js | awk "/name: \"$machineName\"/,/resuelta:/" | grep -vE "id:|sku:|resuelta:" | tr -d '"' | tr -d ',' | sed 's/^ *//')"

    if [ "$machineNameCheck" ]; then
   	 echo -e "\nListando maquinas: ${green}$machineName\n${end}"
	 cat bundle.js | awk "/name: \"$machineName\"/,/resuelta:/" | grep -vE "id:|sku:|resuelta:" | tr -d '"' | tr -d ',' | sed 's/^ *//'
    else
	 echo -e "\n${red}La maquina proporcionada no existe${end}"
    fi
}


function searchIpAddress(){ 
    ipAddress="$1"
    machineName="$(cat bundle.js | grep "ip: \"$ipAddress\"" -B 3 | grep "name: " | awk 'NF{print $NF}' | tr -d '"' | tr -d ',')"

    if [ "$machineName" ]; then
	echo -e "\nLa maquina correspondiente para la IP $ipAddress es: ${green}$machineName\n${end}"
    else
	echo -e "\n${red}La IP proporcionada no corresponde a ninguna maquina${end}"
    fi

}

function searchLink(){
    machineName="$1"
    youtubeLink="$(cat bundle.js | awk "/name: \"$machineName\"/,/resuelta:/" | grep -vE "id:|sku:|resuelta:" | tr -d '"' | tr -d ',' | sed 's/^ *//' | grep youtube | awk 'NF{print $NF}')"
    
   if [ "$youtubeLink" ]; then
	echo -e "\n${green}El tutorial de yootube es: $youtubeLink${end}"
   else
	echo -e "\n${red}Este Link no existe${end}"
   fi

}

function searchDificulty(){

    difficulty="$1"
    result="$(cat bundle.js | grep "dificultad: \"$difficulty\"" -B 5 | grep "name:" | awk 'NF{print $NF}' | tr -d '"' | tr -d ',' | column)"
    if [ "$result" ]; then
	echo -e "\n${green}La dificultad es: $difficulty${end}\n"
	cat bundle.js | grep "dificultad: \"$difficulty\"" -B 5 | grep "name:" | awk 'NF{print $NF}' | tr -d '"' | tr -d ',' | column
    else
	echo -e "\n${red}La dificultad ingresada no existe${end}"
    fi
}

function searchOS(){
     
    os="$1"
    result_os="$(cat bundle.js | grep "so: \"$os\"" -B 5 | grep "name: " | awk 'NF{print $NF}' | tr -d '"' | tr -d ',' | column)"
    if [ "$result_os" ]; then
	echo -e "\n${green}El sistema Operativo de la maquina es: $os${end}\n"
	cat bundle.js | grep "so: \"$os\"" -B 5 | grep "name: " | awk 'NF{print $NF}' | tr -d '"' | tr -d ',' | column
    else
	echo -e "\n${red}El sistema operativo ingresado no existe${end}"
    fi
}

function getOsDifficulty(){
    
    difficulty="$1"
    os="$2"
    
    result_check="$(cat bundle.js | grep "so: \"$os\"" -C 4 | grep "dificultad: \"$difficulty\"" -B 5 | grep "name: " | awk 'NF{print $NF}' | tr -d '"' | tr -d ',' | column)"
    if [ "$result_check" ]; then
	echo -e "\n${green}Listando las maquina de dificultad $difficulty que tengan sistema operativo $os son:\n${end}"
	cat bundle.js | grep "so: \"$os\"" -C 4 | grep "dificultad: \"$difficulty\"" -B 5 | grep "name: " | awk 'NF{print $NF}' | tr -d '"' | tr -d ',' | column
   else
	echo -e "\n${red}[!] Se ha ingresado una dificultad o sistema operativo incorrecto${end}"
   fi
}

#Indicador
declare -i parameter_counter=0

#Regla
declare -i regla_difficulty=0
declare -i regla_os=0

while getopts "m:ui:y:d:o:h" arg; do
    case $arg in
      m) machineName="$OPTARG"; let parameter_counter+=1;;
      u) let parameter_counter+=2;;
      i) ipAddress="$OPTARG"; let parameter_counter+=3;;
      y) machineName="$OPTARG"; let parameter_counter+=4;;
      d) difficulty="$OPTARG"; regla_difficulty=1; let parameter_counter+=5;;
      o) os="$OPTARG"; regla_os=1;let parameter_counter+=6;;
      h) ;;
    esac
done

if [ $parameter_counter -eq 1 ]; then
      searchMachine $machineName
elif [ $parameter_counter -eq 2 ]; then
      updateFiles
elif [ $parameter_counter -eq 3 ]; then
      searchIpAddress $ipAddress
elif [ $parameter_counter -eq 4 ]; then
      searchLink  $machineName
elif [ $parameter_counter -eq 5 ]; then
      searchDificulty $difficulty
elif [ $parameter_counter -eq 6 ]; then
      searchOS $os
elif [ $regla_difficulty -eq 1 ] && [ $regla_os -eq 1 ]; then
     getOsDifficulty $difficulty $os
else
     helpPanel
fi

