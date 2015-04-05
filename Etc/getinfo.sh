source config.sh

curl "${API}/?method=artist.getInfo&artist=Grouper&api_key=${API_KEY}&format=json" | jq '.'

printf "\n"

