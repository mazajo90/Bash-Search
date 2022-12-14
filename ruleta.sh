#!/bin/bash

#Colors
green="\e[0:32m\033[1m"
red="\e[0:31m\033[1m"
yellow="\e[0:33m\033[1m"
blue="\e[0;34m\033[1m"

function ctrl_c(){
    echo -e "${red}\n\n[!]Saliendo...${end}"
    tput cnorm &&  exit 1
}

trap ctrl_c INT

function helpPanel(){
    echo -e "\n${yellow}Uso del sistema:${end} ${green}$0${end}"
    echo -e "\t${green}-m) Ingrese la cantidad de dinero${end}"
    echo -e "\t${green}-t) Seleccione la técnica que desea emplear${end}${yellow} (martingala / labruchere)${end}"
    exit 1
}

function martingala(){
    echo -e "\n${yellow}Dinero actual:${end} ${green}$money${end}"
    echo -ne "${yellow}¿Con cuanto dinero quieres apostar?:${end}" && read initial_a
    echo -ne "${yellow}¿Que apuesta realizaras? (par/impar):${end}" && read par_impar
    
    echo -e "\n${green}Vamos a jugar con la cantidad de $initial_a${end} a $par_impar"
    
    backup_initial=$initial_a
    tput civis
    while true; do
        money=$(($money-initial_a))
        echo -e "\n${green}[!] Acabas de apostar${end} ${yellow}$initial_a${end}, ${green}y tu saldo actual es${end} ${yellow}$money${end}"
        random_number="$(($RANDOM % 37))"
        echo -e "\n${green}[+] Ha salido el numero:${end}${yellow}$random_number${end}"
        
        if [ ! "$money" -le 0 ]; then
            if [ "$par_impar" == "par" ]; then
                if [ "$(($random_number % 2 ))" -eq 0 ]; then
                    if [ "$random_number" -eq 0 ]; then
                        echo -e "${red}El numero que ha salido es 0, perdiste${end}"
                        initial_a=$(($initial_a * 2))
                        echo -e "[!]Tu saldo ahora es de $money"
                    else
                        echo -e "${green}El numero que ha salido es par${end}, ${blue}¡Haz ganado!${end}"
                        reward=$(($initial_a * 2))
                        echo -e "${green}[+] Has ganado la cantidad de${end} ${yellow}$reward${end}"
                        money=$(($money + $reward))
                        echo -e "[!] Tu nuevo saldo es de ${green}$money${end}"
                        backup_initial=$initial_a
                    fi
                else
                    if [ "$(($random_number % 2 ))" -eq 1 ]; then
                        reward=$(($initial_a * 2))
                        money=$(($money + $reward))
                        backup_initial=$initial_a
                    else
                        initial_a=$(($initial_a * 2))
                    fi
                    echo -e "${red}[!]El numero que ha salido es impar, Acabas de perder${end}"
                    initial_a=$(($initial_a * 2))
                    echo -e "[!]Tu saldo ahora es de $money"
                fi
                #sleep 5
            fi
        else
            echo -e "${red}Te haz quedado sin dinero${end}"
            tput cnorm; exit 0
        fi
    done
    tput cnorm
}

function labruchere(){

	echo -e "\n${yellow}Dinero actual:${end} ${green}$money${end}"
	echo -ne "${yellow}¿Que apuesta realizaras? (par/impar)${end} :" && read par_impar

	declare -a my_seq=(1 2 3 4)

	echo -e "${yellow}[+] Comenzamos con la secuencia${end} ${green}[${my_seq[@]}]${end}"
	
	bte=$((${my_seq[0]} + ${my_seq[-1]}))
	unset my_seq[0]
	unset my_seq[-1]
	my_seq=(${my_seq[@]})

	echo -e "${yellow}Invertimos${green} "$bte"$ ${end}${yellow}y nuestra secuencia se queda en${end}${green}[${my_seq[@]}]${end}"
	
	tput civis
	while true; do
	    random_number=$(($RANDOM % 37))
	    echo -e "${yellow}El numero que ha salido es el${end} ${green}$random_number${end}"
	     if [ "$par_impar" == "par"  ]; then
		if [ "$(($random_number % 2))" -eq 0 ]; then
		  echo -e "${yellow}[+] El numero es par${end}, ${green}¡¡haz ganado!!${end}"
		else
		  echo -e "${red}[!] El numero que ha salido es impar, ¡haz perdido!${end}"
		fi
	     fi
	    sleep 5
	
	tput cnorm
	done
}

while getopts "m:t:h" arg; do
    case $arg in
        m) money="$OPTARG";;
        t) technique="$OPTARG";;
        h) helpPanel;;
    esac
done

if [ $money ] && [ $technique ]; then
    if [ "$technique" == "martingala" ]; then
        martingala
    elif [ "$technique" == "labruchere" ]; then
	labruchere
    else
        echo -e "\n${red}La técnica ingresada no existe${end}"
        helpPanel
    fi
else
    helpPanel
fi
