source config.sh

curl "${API}/?method=artist.getsimilar&artist=Kanye%20West&api_key=${API_KEY}&format=json" | jq '.'

printf "\n"

