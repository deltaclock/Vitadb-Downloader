#!/bin/bash
echo "Choose your action"
echo -e "Type: \n'h' for Homebrews \n'p' for Plugins"
read a
if [ $a == h ]; then
  n=$(curl -s https://rinnegatamante.it/vitadb/list_hbs_json.php | jq -r 'keys' | tail -n 2 | sed -n 1p)
  echo "Currenty in the db there are" $n "Homebrews"
  echo "Your last Homebrew was :"
  cat log.txt | head -n 1
  echo -e "Where do you want the dl to stop? \nSTART COUNTING FROM 0!!"
  echo "Waiting for input"
  read x
  mkdir hb
  curl -s https://rinnegatamante.it/vitadb/list_hbs_json.php >> hb/db.json
  for (( i=0; i<=$x; i++ )); do
    filename=$(jq --arg i $i -r '.[$i | tonumber] | "\(.name)_\(.version)"' hb/db.json)
    data=$(jq --arg i $i -r '.[$i | tonumber] | "\(.data)"' hb/db.json)
    if [ "$data" != "" ]; then
      wget -O data${filename// /_} $data
    fi
    jq --arg i $i -r '.[$i | tonumber] | "\(.url)"' hb/db.json | xargs wget -O ${filename// /_}
  done
  jq -r '.[0] | "\(.name)_\(.version)"' hb/db.json > log.txt
  rm hb/db.json
elif [ $a == p ]; then
  n=$(curl -s https://rinnegatamante.it/vitadb/list_plugins_json.php | jq -r 'keys' | tail -n 2 | sed -n 1p)
  echo "Currenty in the db there are" $n "Plugins"
  echo "Your last Plugin was :"
  cat log.txt | tail -n 1
  sed -i '$ d' log.txt
  echo -e "Where do you want the dl to stop? \nSTART COUNTING FROM 0"
  echo "Waiting for input"
  read x
  mkdir pg
  curl -s https://rinnegatamante.it/vitadb/list_plugins_json.php >> pg/db.json
  for (( i=0; i<=$x; i++ )); do
    filename=$(jq -r '.[$i | tonumber] | "\(.name)_\(.version)"' pg/db.json)
    jq -r '.[$i | tonumber] | "\(.url)"' pg/db.json | xargs wget -O ${filename// /_}
  done
  jq -r '.[0] | "\(.name)_\(.version)"' pg/db.json >> log.txt
  rm pg/db.json
else
  echo "EXITING"
  exit;
fi
