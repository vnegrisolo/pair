#!/bin/sh

pair_configure() {
  user1=${1}

  user_response=$(curl "https://api.github.com/users/${1}")
  email=$(echo "${user_response}" | grep '"email":')
  email="${email/[ ]*\"email\": \"}"
  git config pair.author.email "${email/\",}"

  name=$(echo "${user_response}" | grep '"name":')
  name="${name/[ ]*\"name\": \"}"
  git config pair.author.name "${name/\",}"
}

pair() {
  if [ "${1}" == "commit" ]; then
    git $@;
  else
    pair_configure $@
  fi
}
