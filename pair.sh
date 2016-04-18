#!/bin/sh

RED="$(tput setaf 1)"
MAGENTA="$(tput setaf 5)"
CYAN="$(tput setaf 6)"
RESET="$(tput sgr0)"

GITHUB_API='https://api.github.com'

pair_get() {
  field=${1}

  git config --global --get pair.${field}
}

pair_set() {
  type=${1}
  email=${2}
  name=${3}

  git config --global ${type}.email "${email}"
  git config --global ${type}.name "${name}"
}

pair_status() {
  author_name="`pair_get author.name`"
  author_email="`pair_get author.email`"
  committer_name="`pair_get committer.name`"
  committer_email="`pair_get committer.email`"

  echo "Author    => ${MAGENTA}${author_name} <${author_email}>${RESET}"
  echo "Committer => ${CYAN}${committer_name} <${committer_email}>${RESET}"
}

pair_reset() {
  pair_set "pair.author"
  pair_set "pair.committer"
}

pair_configure() {
  type=${1}
  user=${2}
  prefix=' *"[a-zA-Z]*": *"\{0,1\}'
  suffix='\(null\)\{0,1\}"\{0,1\},\{0,1\}'

  response=$(curl "${GITHUB_API}/users/${user}")
  email=$(echo "${response}" | grep '"email":' | sed "s/^${prefix}//" | sed "s/${suffix}$//")
  name=$(echo "${response}" | grep '"name":' | sed "s/^${prefix}//" | sed "s/${suffix}$//")

  if [ -n "${name}" ] && [ -n "${email}" ]; then
    pair_set "${type}" "${email}" "${name}"
  else
    echo "${RED}ERROR${RESET} => You need to set Name and Email for ${user} on Github, or run manually:"
    echo "  git config --global ${type}.email 'your@email.com'"
    echo "  git config --global ${type}.name 'Your Name'"
  fi
}

pair_commit() {
  author_name="`pair_get author.name`"
  author_email="`pair_get author.email`"
  committer_name="`pair_get committer.name`"
  committer_email="`pair_get committer.email`"

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
