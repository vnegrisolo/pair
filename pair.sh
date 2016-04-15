#!/bin/sh

pair_configure() {
  response=$(curl "https://api.github.com/users/${1}")
  email=$(echo "${response}" | grep '"email":')
  email="${email/[ ]*\"email\": \"}"
  git config pair.author.email "${email/\",}"

  name=$(echo "${response}" | grep '"name":')
  name="${name/[ ]*\"name\": \"}"
  git config pair.author.name "${name/\",}"

  if [ -n "${2}" ]; then
    response=$(curl "https://api.github.com/users/${2}")
    email=$(echo "${response}" | grep '"email":')
    email="${email/[ ]*\"email\": \"}"
    git config pair.committer.email "${email/\",}"

    name=$(echo "${response}" | grep '"name":')
    name="${name/[ ]*\"name\": \"}"
    git config pair.committer.name "${name/\",}"
  fi
}

pair() {
  if [ "${1}" == "commit" ]; then
    git $@;
  else
    pair_configure $@
  fi
}
