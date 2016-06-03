#!/bin/sh

RED="$(tput setaf 1)"
GREEN="$(tput setaf 2)"
BLUE="$(tput setaf 4)"
RESET="$(tput sgr0)"

GITHUB_API='https://api.github.com'

pair_reset() {
  unset GIT_{AUTHOR,COMMITTER}_{EMAIL,NAME}

  git config --remove-section pair &> /dev/null
}

pair_status() {
  author="$(git config --get pair.author)"
  committer="$(git config --get pair.committer)"

  echo "Author    => ${GREEN}${author}${RESET}"
  echo "Committer => ${BLUE}${committer}${RESET}"
  echo "Last 10 commits:"
  git log -10 --pretty=format:"%h => %Cgreen%an %Creset=> %Cblue%cn %Creset=> %s"
}

pair_configure() {
  type=${1}
  user=${2}

  name="$(git config --global --get pair.${user}.name)"
  email="$(git config --global --get pair.${user}.email)"

  if [ -z "$name" ] || [ -z "$email" ]; then
    prefix=' *"[a-zA-Z]*": *"\{0,1\}'
    suffix='\(null\)\{0,1\}"\{0,1\},\{0,1\}'

    response=$(curl "${GITHUB_API}/users/${user}")
    email=$(echo "$response" | grep '"email":' | sed "s/^${prefix}//" | sed "s/${suffix}$//")
    name=$(echo "$response" | grep '"name":' | sed "s/^${prefix}//" | sed "s/${suffix}$//")
  fi

  if [ -z "$name" ] || [ -z "$email" ]; then
    echo "Your email/name couldn't be fetch on github"
    echo -n "Type your \e[31memail\e[0m: "; read email
    echo -n "Type your \e[31mname\e[0m: ";  read name
  fi

  if [ -n "$name" ] && [ -n "$email" ]; then
    git config --global pair.${user}.email "$email"
    git config --global pair.${user}.name "$name"
    git config pair.${type} "$user"
  else
    echo "${RED}ERROR${RESET} => You need to set Name and Email for ${user}"
  fi
}

pair_commit() {
  author="$(git config --get pair.author)"
  committer="$(git config --get pair.committer)"

  if [ -n "$author" ]; then
    export GIT_AUTHOR_NAME="$(git config --global --get pair.${author}.name)"
    export GIT_AUTHOR_EMAIL="$(git config --global --get pair.${author}.email)"
  fi
  if [ -n "$committer" ]; then
    export GIT_COMMITTER_NAME="$(git config --global --get pair.${committer}.name)"
    export GIT_COMMITTER_EMAIL="$(git config --global --get pair.${committer}.email)"
  fi

  git "$@"

  if [ $? -eq 0 ] && [ -n "$committer" ]; then
    git config pair.author "$committer"
    git config pair.committer "$author"
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
