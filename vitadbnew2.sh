#!/bin/bash
clear
echo "Choose your action"
echo -e "Type: \n'h' for Homebrews \n'p' for Plugins"
read a
if [ $a == h ]; then
  n=$(curl -s https://rinnegatamante.it/vitadb/list_hbs_json.php | jq -r 'keys' | tail -n 2 | sed -n 1p)
  echo "Currenty in the db there are" $n "Homebrews, counting from 0"
  echo "Your last Homebrew was :"
  head -n 1 log.txt
  echo -e "Where do you want the dl to stop? \nSTART COUNTING FROM 0!!"
  echo "Waiting for input..."
  read x
  mkdir -p hb && cd hb
  curl -s https://rinnegatamante.it/vitadb/list_hbs_json.php >> db.json
  for (( i=0; i<=$x; i++ )); do
    filename=$(jq --arg i $i -r '.[$i | tonumber] | "\(.name)_\(.version)"' db.json)
    data=$(jq --arg i $i -r '.[$i | tonumber] | "\(.data)"' db.json)
    if [ "$data" != "" ]; then
      wget -O data${filename// /_} $data
    fi
    jq --arg i $i -r '.[$i | tonumber] | "\(.url)"' db.json | xargs wget -O ${filename// /_}
  done
  jq -r '.[0] | "\(.name)_\(.version)"' db.json > ../log.txt
  sed -i '1a\Nothing' log.txt
  rm db.json
elif [ $a == p ]; then
  n=$(curl -s https://rinnegatamante.it/vitadb/list_plugins_json.php | jq -r 'keys' | tail -n 2 | sed -n 1p)
  echo "Currenty in the db there are" $n "Plugins"
  echo "Your last Plugin was :"
  tail -n 1 log.txt
  sed -i '$ d' log.txt
  echo -e "Where do you want the dl to stop? \nSTART COUNTING FROM 0"
  echo "Waiting for input..."
  read x
  curl -s https://rinnegatamante.it/vitadb/list_plugins_json.php >> db.json
  mkdir -p pg && cd pg
  for (( i=0; i<=$x; i++ )); do
    filename=$(jq --arg i $i -r '.[$i | tonumber] | "\(.name)_\(.version)"' ../db.json)
    url=$(jq --arg i $i -r '.[$i | tonumber] | "\(.url)"' ../db.json)
    ext=$(curl -sI $url | grep file_path)
    ext=${ext##*.}
    wget -O ${filename// /_}.$ext $url
  done
  for f in *; do
    mv "$f" "${f%?}"
  done
  echo "Nothing" >> ../log.txt
  jq -r '.[0] | "\(.name)_\(.version)"' ../db.json >> ../log.txt
  rm ../db.json
else
  echo "EXITING"
  exit
fi
