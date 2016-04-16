#!/bin/sh

pair_table_line() {
  printf "| %-9s | %-40s | %-40s |" "${1}" "${2}" "${3}"; echo ""
}

pair_status() {
  pair_table_line "Pair" "Name" "Email"
  pair_table_line "----" "----" "-----"
  pair_table_line "Author" "`git config --get pair.author.name`" "`git config --get pair.author.email`"
  pair_table_line "Committer" "`git config --get pair.committer.name`" "`git config --get pair.committer.email`"
}

pair_set() {
  type=${1}
  email=${2}
  name=${3}

  git config ${type}.email "${email}"
  git config ${type}.name "${name}"
}

pair_configure() {
  type=${1}
  user=${2}

  response=$(curl "https://api.github.com/users/${user}")

  prefix=' *"[a-zA-Z]*": *"\{0,1\}'
  suffix='\(null\)\{0,1\}"\{0,1\},\{0,1\}'

  email=$(echo "${response}" | grep '"email":' | sed "s/^${prefix}//" | sed "s/${suffix}$//")
  name=$(echo "${response}" | grep '"name":' | sed "s/^${prefix}//" | sed "s/${suffix}$//")

  pair_set "${type}" "${email/\",}" "${name/\",}"

  if [ -z "${name}" ] || [ -z "${email}" ]; then
    echo "ERROR => You need to set Name and Email for ${user} on Github"
    return 0;
  fi
}

pair_reset() {
  pair_set "pair.author"
  pair_set "pair.committer"
}

pair_commit() {
  author_name="`git config --get pair.author.name`"
  author_email="`git config --get pair.author.email`"
  committer_name="`git config --get pair.committer.name`"
  committer_email="`git config --get pair.committer.email`"

  if [ -n "${author_email}" ]; then
    pair_set "user" "${author_email}" "${author_name}"
  fi

  git_author=""
  if [ -n "${committer_email}" ]; then
    git_author="--author=\"${committer_name} <${committer_email}>\""

    pair_set "pair.author" "${committer_email}" "${committer_name}"
    pair_set "pair.committer" "${author_email}" "${author_name}"
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
    pair_reset
    pair_configure 'pair.author' $1
    if [ -n "${2}" ]; then
      pair_configure 'pair.committer' $2
    fi
  fi
}
