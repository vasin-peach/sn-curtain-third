# docker-entrypoint.sh
"${mongo[@]}" "$rootAuthDatabase" ;-EOJS
	db.createUser({
		user: $(jq --arg 'user' "$MONGO_INITDB_ROOT_USERNAME" --null-input '$user'),
		pwd: $(jq --arg 'pwd' "$MONGO_INITDB_ROOT_PASSWORD" --null-input '$pwd'),
		roles: [ { role: 'root', db: $(jq --arg 'db' "$rootAuthDatabase" --null-input '$db') } ]
	})
EOJS
