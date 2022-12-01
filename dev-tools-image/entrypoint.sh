#!/bin/bash

# Ensure $HOME exists when starting
if [ ! -d "${HOME}" ]; then
  mkdir -p "${HOME}"
fi

# Setup $PS1 for a consistent and reasonable prompt
if [ -w "${HOME}" ] && [ ! -f "${HOME}"/.zshrc ]; then
  echo "PS1='[\u@\h \W]\$ '" > "${HOME}"/.zshrc
fi

# Add current (arbitrary) user to /etc/passwd and /etc/group
if ! whoami &> /dev/null; then
  if [ -w /etc/passwd ]; then
    echo "${USER_NAME:-user}:x:$(id -u):0:${USER_NAME:-user} user:${HOME}:/bin/zsh" >> /etc/passwd
    echo "${USER_NAME:-user}:x:$(id -u):" >> /etc/group
  fi
fi

# Configure /etc/subuid & /etc/subgid for rootless podman
echo $(id -u):1100000000:65536 >> /etc/subuid
echo $(id -u):1100000000:65536 >> /etc/subgid

tail -f /dev/null
