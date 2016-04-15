#!/bin/sh

pair_status() {
  echo "|-----------|------------------------------------------|------------------------------------------|"
  echo "| Pair      | Name                                     | Email                                    |"
  echo "|-----------|------------------------------------------|------------------------------------------|"
  printf "| Author    | %40s | %40s |" "`git config --get pair.author.name`" "`git config --get pair.author.email`"; echo ""
  printf "| Committer | %40s | %40s |" "`git config --get pair.committer.name`" "`git config --get pair.committer.email`"; echo ""
  echo "|-----------|------------------------------------------|------------------------------------------|"
}

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
  if [ -z "${1}" ]; then
    pair_status;
  elif [ "${1}" == "commit" ]; then
    git $@;
  else
    pair_configure $@
  fi
}
