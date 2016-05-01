#!/bin/sh

RED="$(tput setaf 1)"
GREEN="$(tput setaf 2)"
BLUE="$(tput setaf 4)"
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

  git config --global --remove-section pair.author &> /dev/null
  git config --global --remove-section pair.committer &> /dev/null
}

pair_status() {
  author="$(pair_get author.name) <$(pair_get author.email)>"
  committer="$(pair_get committer.name) <$(pair_get committer.email)>"

  echo "Author    => ${GREEN}${author}${RESET}"
  echo "Committer => ${BLUE}${committer}${RESET}"
  echo "Last 10 commits:"
  git log -10 --pretty=format:"%h => %Cgreen%an %Creset=> %Cblue%cn %Creset=> %s"
}

pair_configure() {
  type=${1}
  user=${2}

  name="$(pair_get ${user}.name)"
  email="$(pair_get ${user}.email)"

  if [ -z "$name" ] || [ -z "$email" ]; then
    prefix=' *"[a-zA-Z]*": *"\{0,1\}'
    suffix='\(null\)\{0,1\}"\{0,1\},\{0,1\}'

    response=$(curl "${GITHUB_API}/users/${user}")
    email=$(echo "$response" | grep '"email":' | sed "s/^${prefix}//" | sed "s/${suffix}$//")
    name=$(echo "$response" | grep '"name":' | sed "s/^${prefix}//" | sed "s/${suffix}$//")
  fi

  if [ -n "$name" ] && [ -n "$email" ]; then
    pair_set "$type" "$email" "$name"
    pair_set "$user" "$email" "$name"
  else
    echo "${RED}ERROR${RESET} => You need to set Name and Email for ${user} on Github, or run manually:"
    echo "  git config --global pair.${type}.email 'your@email.com'"
    echo "  git config --global pair.${type}.name 'Your Name'"
    echo "  git config --global pair.${user}.email 'your@email.com'"
    echo "  git config --global pair.${user}.name 'Your Name'"
  fi
}

pair_commit() {
  export GIT_AUTHOR_NAME="$(pair_get author.name)"
  export GIT_AUTHOR_EMAIL="$(pair_get author.email)"
  export GIT_COMMITTER_NAME="$(pair_get committer.name)"
  export GIT_COMMITTER_EMAIL="$(pair_get committer.email)"

  git "$@"

  if [ $? -eq 0 ] && [ -n "$GIT_COMMITTER_NAME" ] && [ -n "$GIT_COMMITTER_EMAIL" ]; then
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
