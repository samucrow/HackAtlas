#!/bin/bash

#Colors
greenColor="\033[0;32m\033[1m"
endColor="\033[0m\033[0m"
redColor="\033[0;31m\033[1m"
blueColor="\033[0;34m\033[1m"
yellowColor="\033[0;33m\033[1m"
purpleColor="\033[0;35m\033[1m"
turquoiseColor="\033[0;36m\033[1m"
grayColor="\033[0;37m\033[1m"

# Variables Globales
main_url="https://samucrow.github.io/writeups/"
fileName="machines.txt"
fileName_temp="machines_temp.txt"
md5Now=""
updatedFile="$(curl -s $main_url | grep "MÁQUINA" | sed 's/.*">//' | sed 's/<\/[^>]*>//' | awk '{gsub(/ <br>/, ""); print}' | sed 's/ (/->/' | tr -d '()' | sed 's/<!--/->,/; s/-->//g; s/<!--/->/g; s/HTB/HackTheBox/; s/THM/TryHackMe/; s/MÁQUINA//; s/, /,/g' > $fileName_temp && md5sum $fileName_temp | awk '{print $1}')"

function ctrl_c(){
  echo -e "${yellowColor}\n\n[!] ${redColor}Saliendo...\n${endColor}"
  tput cnorm
  stty echo
  exit 1
}

# Ctrl + C
trap ctrl_c INT

# Funciones
function helpPanel(){
  echo -e "\n${blueColor}[~] ${grayColor}Uso: ${endColor}\n"
  echo -e "\t${greenColor}-u: ${endColor}Descargar/Actualizar nuevas máquinas.\n"
  echo -e "\t${greenColor}-m: ${endColor}Buscar máquinas por ${greenColor}nombre${endColor}.\n"
  echo -e "\t${greenColor}-s: ${endColor}Buscar máquinas por ${greenColor}skills${endColor}.\n"
  echo -e "\t${greenColor}-d: ${endColor}Buscar máquinas por ${greenColor}dificultad${endColor} (Easy, Medium, Hard).\n"
  echo -e "\t${greenColor}-p: ${endColor}Buscar máquinas por ${greenColor}plataforma${endColor} (HackTheBox, TryHackMe, etc).\n"
  echo -e "\t${greenColor}-o: ${endColor}Buscar máquinas por ${greenColor}sistema operativo${endColor} (Linux o Windows).\n"
  echo -e "\t${greenColor}-h: ${endColor}Mostrar este panel de ayuda.\n"
}

function updateMachines(){
  tput civis
  stty -echo
  if [[ ! -f $fileName ]];then
    echo -e "\n${yellowColor}[@] ${blueColor}Comenzando Actualización...${endColor}\n"
    sleep 0.3
    echo -e "${purpleColor}~~~${grayColor}Descargando archivos necesarios${purpleColor}~~~${endColor}\n"
    curl -s $main_url | grep "MÁQUINA" | sed 's/.*">//; s/<\/[^>]*>//' | awk '{gsub(/ <br>/, ""); print}' | sed 's/ (/->/' | tr -d '()' | sed 's/<!--/->,/; s/-->//g; s/<!--/->/g; s/HTB/HackTheBox/; s/THM/TryHackMe/; s/MÁQUINA//; s/, /,/g' > $fileName
    sleep 0.8
    echo -e "${greenColor}[+] Actualización Completada!${endColor}\n"
  else
    md5Now="$(md5sum $fileName | awk '{ print $1 }')"
    echo -e "\n${yellowColor}[+]${grayColor} Archivo en el sistema: ${purpleColor}$md5Now${purpleColor}\n"
    echo -e "${yellowColor}[+]${grayColor} Archivo actualizado: ${purpleColor}$updatedFile${purpleColor}\n"
    checkUpdates
  fi
  tput cnorm
  stty echo
}

function checkUpdates(){
  if [[ -f $fileName ]]; then
    md5Now="$(md5sum $fileName | awk '{ print $1 }')"

    if [[ $md5Now == $updatedFile ]];then
      echo -e "${greenColor}[+] ${endColor}Los archivos están actualizados\n"
    else
     echo -e "\n${blueColor}[!]${grayColor} Hay actualizaciones disponibles!${endColor}"
     askUpdate
    fi
  else
    echo -e "\n${redColor}[X]${grayColor} No existe el archivo $fileName.${endColor}"
  fi
}

function askUpdate(){
  while true; do
    tput cnorm
    stty echo
    echo -en "\n${yellowColor}[?] ${grayColor}¿Quieres actualizar los archivos? (y/n):${endColor} "
    stty -icanon
    read -n 1 response
    echo
    response=$(echo "$response" | tr '[:upper:]' '[:lower:]')

    if [[ $response == y || $response == n ]];then
      case "$response" in
        y) 
          rm $fileName
          updateMachines
          break
          ;;
        n) break ;;
      esac
    else
      tput cuu 2
      tput ed
    fi
  done
}

function searchMachines(){

# Buscar si el archivo de máquinas existe
  if [[ ! -f $fileName ]]; then
    echo -e "\n${redColor}[!]${endColor} El archivo ${grayColor}${fileName}${endColor} no existe o no está actualizado, por favor, aplica el parámetro ${grayColor}'-u'${endColor} sin argumentos adicionales o utiliza ${grayColor}'-h'${endColor} para ver las opciones disponibles\n"
    
    exit 1
  fi

  machine="$(echo -n "$machine" | tr '[:lower:]' '[:upper:]' | xargs )"

# Comprobar si existen coincidencias de lo establecido por el usuario
  if awk -F'->' '{print $1}' $fileName | grep -i "$machine" >/dev/null; then

    searchResult=$(awk -F'->' '{print $1}' "$fileName" | grep -i "$machine" | awk -F'->' '{print $1}' | sed 's/^[ \t]*//g;s/^[ \t]*$//g;s/ /+/g')

     for result in $searchResult; do
      result="$(echo -n "$result" | sed 's/+/ /g')"
      search_machineName="$(cat $fileName | grep "$result" | awk -F'->' '{print $1}')"
      search_platform="$(cat $fileName | grep "$result" | awk -F'->' '{print $2}' | sed 's/HACKTHEBOX/HackTheBox/; s/TRYHACKME/TryHackMe/; s/SAMUCROW/By SamuCrow/')"
      search_skills="$(cat $fileName | grep "$result" | awk -F'->' '{print $3}' | sed 's/,/\n\t- /g')"
      search_difficulty="$(cat $fileName | grep "$result" | awk -F'->' '{print $4}')"

      link="$(echo -n "https://samucrow.github.io/writeups/$result" | tr '[:upper:]' '[:lower:]' | sed 's/ //g')"

      echo -e "\n${turquoiseColor}[·]${yellowColor}$search_machineName ${grayColor}-> ${blueColor}$search_platform\n\n${greenColor}  Dificultad: ${grayColor}$search_difficulty\n\n${purpleColor}  Link: ${grayColor}$link${endColor}\n\n${redColor}  Skills: ${grayColor}$search_skills\n"


    done
  else
    echo -e "\n${redColor}[X]${grayColor} No se encontraron coincidencias en base al nombre ${blueColor}$machine${grayColor}.${endColor}\n"

    exit 1
  fi
}

function searchSkills(){

  if [[ ! -f $fileName ]]; then
    echo -e "\n${redColor}[!]${endColor} El archivo ${grayColor}${fileName}${endColor} no existe o no está actualizado, por favor, aplica el parámetro ${grayColor}'-u'${endColor} sin argumentos adicionales o utiliza ${grayColor}'-h'${endColor} para ver las opciones disponibles\n"
    
    exit 1
  fi

  if awk -F'->' '{print $3}' $fileName | grep -i "$skills" >/dev/null; then

    searchResult=$(eval "grep -Ff <(awk -F'->' '{print \$3}' $fileName | grep -i '$skills') $fileName | awk -F'->' '{print \$1}'" | sed 's/^[ \t]*//g;s/^[ \t]*$//g;s/ /+/g')

    echo -e "${redColor}[*]${blueColor} Las máquinas relacionadas con la skill ${yellowColor}$skills${blueColor} son: ${endColor}\n"

    for result in $searchResult; do

      result="$(echo -n "$result" | sed 's/+/ /g' | tr '[:upper:]' '[:lower:]')"
      echo -e "\t${result^}"

    done | xargs -d '\n' -n 3 printf "%-25s%-25s%-25s%-25s\n\n"

  else
    echo -e "\n${redColor}[X]${grayColor} La skill ${blueColor}$skills${grayColor} no existe.${endColor}\n"

    exit 1
  fi
}

function searchDifficulty(){

  if [[ ! -f $fileName ]]; then
    echo -e "\n${redColor}[!]${endColor} El archivo ${grayColor}${fileName}${endColor} no existe o no está actualizado, por favor, aplica el parámetro ${grayColor}'-u'${endColor} sin argumentos adicionales o utiliza ${grayColor}'-h'${endColor} para ver las opciones disponibles\n"
    
    exit 1
  fi

  difficulty="$(echo -n $difficulty | sed 's/facil/Easy/I; s/fácil/Easy/I; s/media/Medium/I; s/dificil/Hard/I; s/difícil/Hard/I; s/hard/Hard/I; s/medium/Medium/I; s/easy/Easy/I')"

  if awk -F'->' '{print $4}' $fileName | grep -i "$difficulty" >/dev/null; then

    searchResult=$(eval "grep -Ff <(awk -F'->' '{print \$4}' $fileName | grep -i '$difficulty') $fileName | awk -F'->' '{print \$1}'" | sed 's/^[ \t]*//g;s/^[ \t]*$//g;s/ /+/g')
    echo -e "${redColor}[*]${blueColor} Mostrando máquinas de dificultad ${yellowColor}$difficulty${blueColor}: ${endColor}\n"

    for result in $searchResult; do

      result="$(echo -n "$result" | sed 's/+/ /g' | tr '[:upper:]' '[:lower:]')"

      echo -e "\t${result^}"

    done | xargs -d '\n' -n 3 printf "%-25s%-25s%-25s%-25s\n\n"

  else
    echo -e "\n${redColor}[X]${grayColor} La dificultad ${blueColor}$difficulty${grayColor} no existe :(${endColor}\n"

    exit 1
  fi

}

function searchPlatform(){

  if [[ ! -f $fileName ]]; then
    echo -e "\n${redColor}[!]${endColor} El archivo ${grayColor}${fileName}${endColor} no existe o no está actualizado, por favor, aplica el parámetro ${grayColor}'-u'${endColor} sin argumentos adicionales o utiliza ${grayColor}'-h'${endColor} para ver las opciones disponibles\n"
    
    exit 1
  fi

  platform="$(echo -n "$platform" | sed 's/htb/HackTheBox/I; s/hackthebox/HackTheBox/I; s/thm/TryHackMe/I; s/tryhackme/TryHackMe/I; s/samucrow/SamuCrow/I')"

  if awk -F'->' '{print $2}' $fileName | grep -i "$platform" >/dev/null; then

    searchResult=$(eval "grep -Ff <(awk -F'->' '{print \$2}' $fileName | grep -i '$platform') $fileName | awk -F'->' '{print \$1}'" | sed 's/^[ \t]*//g;s/^[ \t]*$//g;s/ /+/g')
    echo -e "${redColor}[*]${blueColor} Las máquinas de ${yellowColor}$platform${blueColor} son: ${endColor}\n\t"

    for result in $searchResult; do

      result="$(echo -n "$result" | sed 's/+/ /g' | tr '[:upper:]' '[:lower:]')"

      echo -e "\t${result^}"

    done | xargs -d '\n' -n 3 printf "%-25s%-25s%-25s%-25s\n\n"

  else
    echo -e "\n${redColor}[X]${grayColor} La plataforma ${blueColor}$platform${grayColor} no existe en los registros.${endColor}\n"

    exit 1
  fi

}

function searchOS(){

  if [[ ! -f $fileName ]]; then
    echo -e "\n${redColor}[!]${endColor} El archivo ${grayColor}${fileName}${endColor} no existe o no está actualizado, por favor, aplica el parámetro ${grayColor}'-u'${endColor} sin argumentos adicionales o utiliza ${grayColor}'-h'${endColor} para ver las opciones disponibles\n"
    
    exit 1
  fi

  os="$(echo -n "$os" | sed 's/linux/Linux/I; s/windows/Windows/I; s/android/Android/I')"

  if awk -F'->' '{print $5}' $fileName | grep -i "$os" >/dev/null; then

    searchResult=$(eval "grep -Ff <(awk -F'->' '{print \$5}' $fileName | grep -i '$os') $fileName | awk -F'->' '{print \$1}'" | sed 's/^[ \t]*//g;s/^[ \t]*$//g;s/ /+/g')
    echo -e "${redColor}[*]${blueColor} Mostrando las máquinas con Sistema Operativo ${yellowColor}$os${blueColor}: ${endColor}\n"

    for result in $searchResult; do

      result="$(echo -n "$result" | sed 's/+/ /g' | tr '[:upper:]' '[:lower:]')"

      echo -e "\t${result^}"

    done | xargs -d '\n' -n 3 printf "%-25s%-25s%-25s%-25s\n\n"

  elif [ $os ==  "Android" ];then
    echo -e "\n${redColor}[X]${grayColor} El sistema operativo ${blueColor}$os${grayColor} no está disponible por el momento.${endColor}\n"
  else
    echo -e "\n${redColor}[X]${grayColor} El sistema operativo ${blueColor}$os${grayColor} no existe.${endColor}\n"

    exit 1
  fi

}

function searchMany(){

  if [[ ! -f $fileName ]]; then
    echo -e "\n${redColor}[!]${endColor} El archivo ${grayColor}${fileName}${endColor} no existe o no está actualizado, por favor, aplica el parámetro ${grayColor}'-u'${endColor} sin argumentos adicionales o utiliza ${grayColor}'-h'${endColor} para ver las opciones disponibles\n"
    
    exit 1
  fi

  os="$(echo -n "$os" | sed 's/linux/Linux/I; s/windows/Windows/I; s/android/Android/I; s/ios/IOS/I; s/ //')"
  platform="$(echo -n "$platform" | sed 's/htb/HackTheBox/I; s/hackthebox/HackTheBox/I; s/thm/TryHackMe/I; s/tryhackme/TryHackMe/I; s/samucrow/SamuCrow/I; s/ //')"
  difficulty="$(echo -n $difficulty | sed 's/facil/Easy/I; s/fácil/Easy/I; s/media/Medium/I; s/dificil/Hard/I; s/difícil/Hard/I; s/hard/Hard/I; s/medium/Medium/I; s/easy/Easy/I; s/ //')"
  if ! awk -F'->' '{print $2}' $fileName | grep -i "$platform" >/dev/null; then

    echo -e "\n${redColor}[!]${grayColor} La plataforma ${blueColor}$platform${grayColor} no se encuentra en los registros.${endColor}\n"
    exit 1

  elif ! awk -F'->' '{print $4}' $fileName | grep -i "$difficulty" >/dev/null; then

    echo -e "\n${redColor}[!]${grayColor} La dificultad ${blueColor}$difficulty${grayColor} no existe.${endColor}\n"
    exit 1

  elif ! awk -F'->' '{print $5}' $fileName | grep -i "$os" >/dev/null; then
    if [ $os == "Android" ]; then

      echo -e "\n${redColor}[X]${grayColor} El sistema operativo ${blueColor}$os${grayColor} no está disponible por el momento.${endColor}\n"
      exit 1

    else

      echo -e "\n${redColor}[!]${grayColor} El sistema operativo ${blueColor}$os${grayColor} no existe.${endColor}\n"
      exit 1

    fi
  else

    echo -e "${redColor}[*]${blueColor} Mostrando las máquinas con los parámetros [${yellowColor}$os $difficulty $platform${blueColor}]: ${endColor}\n"
    cat machines.txt | grep -i "$platform" | grep -i "$difficulty" | grep -i "$os" | awk -F'->' '{print $1}' | tr [:upper:] [:lower:] | sed 's/^[ \t]*//g; s/^[ \t]*$//g; s/^\(.\)/\U\1/g' | xargs -d '\n' -n 3 printf "\t%-25s%-25s%-25s%-25s\n\n"

  fi
}

# Indicadores
declare -i flag_counter=0

rm $fileName_temp 2>/dev/null

# Snitches
declare -i snitch=0

while getopts "m:hs:ud:p:o:" arg; do
  case $arg in
    m) machine="$OPTARG"; let flag_counter+=1;;
    u) let flag_counter+=2;;
    s) skills="$OPTARG"; let flag_counter+=3;;
    d) difficulty="$OPTARG"; let snitch+=1; let flag_counter+=4;;
    p) platform="$OPTARG"; let snitch+=1; let flag_counter+=5;;
    o) os="$OPTARG"; let snitch+=1; let flag_counter+=6;;
    h) ;;
  esac
done

if [ $flag_counter -eq 1 ]; then
  checkUpdates
  searchMachines $machine
elif [ $flag_counter -eq 2 ]; then
  updateMachines
elif [ $flag_counter -eq 3 ]; then
  checkUpdates
  searchSkills "$skills"
elif [ $flag_counter -eq 4 ]; then
  checkUpdates
  searchDifficulty $difficulty
elif [ $flag_counter -eq 5 ]; then
  checkUpdates
  searchPlatform $platform
elif [ $flag_counter -eq 6 ]; then
  checkUpdates
  searchOS $os
elif [ $snitch -ge 2 ]; then
  checkUpdates
  searchMany $os $platform $difficulty
else
  checkUpdates
  helpPanel
fi
