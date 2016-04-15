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

pair_reset() {
  git config pair.author.name ""
  git config pair.author.email ""
  git config pair.committer.name ""
  git config pair.committer.email ""
}

pair_commit() {
  author_name="`git config --get pair.author.name`"
  author_email="`git config --get pair.author.email`"
  committer_name="`git config --get pair.committer.name`"
  committer_email="`git config --get pair.committer.email`"

  if [ -n "${author_email}" ]; then
    git config user.name "${author_name}"
    git config user.email "${author_email}"
  fi

  git_author=""
  if [ -n "${committer_email}" ]; then
    git_author="--author=\"${committer_name} <${committer_email}>\""

    git config pair.author.name "${committer_name}"
    git config pair.author.email "${committer_email}"
    git config pair.committer.name "${author_name}"
    git config pair.committer.email "${author_email}"
  fi

  git "$@" "${git_author}"
}

pair() {
  if [ -z "${1}" ]; then
    pair_status
  elif [ "${1}" == "reset" ]; then
    pair_reset $@
  elif [ "${1}" == "commit" ]; then
    pair_commit $@
  else
    pair_configure $@
  fi
}
