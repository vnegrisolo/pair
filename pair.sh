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

  git config --global pair.${type}.email "$email"
  git config --global pair.${type}.name "$name"
}

pair_reset() {
  unset GIT_AUTHOR_NAME
  unset GIT_AUTHOR_EMAIL
  unset GIT_COMMITTER_NAME
  unset GIT_COMMITTER_EMAIL

  git config --global --unset pair.author.name
  git config --global --unset pair.author.email
  git config --global --unset pair.committer.name
  git config --global --unset pair.committer.email
}

pair_status() {
  author="$(pair_get author.name) <$(pair_get author.email)>"
  committer="$(pair_get committer.name) <$(pair_get committer.email)>"

  echo "Author    => ${CYAN}${author}${RESET}"
  echo "Committer => ${MAGENTA}${committer}${RESET}"
}

pair_configure() {
  type=${1}
  user=${2}
  prefix=' *"[a-zA-Z]*": *"\{0,1\}'
  suffix='\(null\)\{0,1\}"\{0,1\},\{0,1\}'

  response=$(curl "${GITHUB_API}/users/${user}")
  email=$(echo "$response" | grep '"email":' | sed "s/^${prefix}//" | sed "s/${suffix}$//")
  name=$(echo "$response" | grep '"name":' | sed "s/^${prefix}//" | sed "s/${suffix}$//")

  if [ -n "$name" ] && [ -n "$email" ]; then
    pair_set "$type" "$email" "$name"
  else
    echo "${RED}ERROR${RESET} => You need to set Name and Email for ${user} on Github, or run manually:"
    echo "  git config --global pair.${type}.email 'your@email.com'"
    echo "  git config --global pair.${type}.name 'Your Name'"
  fi
}

pair_commit() {
  export GIT_AUTHOR_NAME="$(pair_get author.name)"
  export GIT_AUTHOR_EMAIL="$(pair_get author.email)"
  export GIT_COMMITTER_NAME="$(pair_get committer.name)"
  export GIT_COMMITTER_EMAIL="$(pair_get committer.email)"

  git "$@"

  if [ -n "$GIT_COMMITTER_NAME" ] && [ -n "$GIT_COMMITTER_EMAIL" ]; then
    pair_set "author" "$GIT_COMMITTER_EMAIL" "$GIT_COMMITTER_NAME"
    pair_set "committer" "$GIT_AUTHOR_EMAIL" "$GIT_AUTHOR_NAME"
  fi
}

pair() {
  if [ -z "$1" ]; then
    pair_status
  elif [ "$1" == "commit" ]; then
    pair_commit "$@"
  elif [ "$1" == "reset" ]; then
    pair_reset
  else
    pair_reset
    pair_configure 'author' $1
    if [ -n "$2" ]; then
      pair_configure 'committer' $2
    fi
  fi
}
