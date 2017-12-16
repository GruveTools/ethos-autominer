#!/usr/bin/env bash

{ # this ensures the entire script is downloaded #

autominer_has() {
  type "$1" > /dev/null 2>&1
}

autominer_install_dir() {
  printf %s "${AUTOMINER_DIR:-"$HOME/ethos-autominer"}"
}

autominer_latest_version() {
  echo "master"
}

#
# Outputs the location to ethOS Autominer depending on:
# * The availability of $AUTOMINER_SOURCE
# * The method used ("script" or "git" in the script, defaults to "git")
# AUTOMINER_SOURCE always takes precedence unless the method is "script-autominer-exec"
#
autominer_source() {
  local AUTOMINER_METHOD
  AUTOMINER_METHOD="$1"
  local AUTOMINER_SOURCE_URL
  AUTOMINER_SOURCE_URL="$AUTOMINER_SOURCE"
  AUTOMINER_SOURCE_URL="https://github.com/Japh/ethos-autominer.git"
  echo "$AUTOMINER_SOURCE_URL"
}

autominer_download() {
  if autominer_has "curl"; then
    curl --compressed -q "$@"
  elif autominer_has "wget"; then
    # Emulate curl with wget
    ARGS=$(echo "$*" | command sed -e 's/--progress-bar /--progress=bar /' \
                           -e 's/-L //' \
                           -e 's/--compressed //' \
                           -e 's/-I /--server-response /' \
                           -e 's/-s /-q /' \
                           -e 's/-o /-O /' \
                           -e 's/-C - /-c /')
    # shellcheck disable=SC2086
    eval wget $ARGS
  fi
}

install_autominer_from_git() {
  local INSTALL_DIR
  INSTALL_DIR="$(autominer_install_dir)"

  if [ -d "$INSTALL_DIR/.git" ]; then
    echo "=> ethOS Autominer is already installed in $INSTALL_DIR, trying to update using git"
    command printf '\r=> '
    command git --git-dir="$INSTALL_DIR"/.git --work-tree="$INSTALL_DIR" fetch origin tag "$(autominer_latest_version)" --depth=1 2> /dev/null || {
      echo >&2 "Failed to update ethOS Autominer, run 'git fetch' in $INSTALL_DIR yourself."
      exit 1
    }
  else
    # Cloning to $INSTALL_DIR
    echo "=> Downloading ethOS Autominer from git to '$INSTALL_DIR'"
    command printf '\r=> '
    mkdir -p "${INSTALL_DIR}"
    if [ "$(ls -A "${INSTALL_DIR}")" ]; then
      command git init "${INSTALL_DIR}" || {
        echo >&2 'Failed to initialize ethOS Autominer repo. Please report this!'
        exit 2
      }
      command git --git-dir="${INSTALL_DIR}/.git" remote add origin "$(autominer_source)" 2> /dev/null \
        || command git --git-dir="${INSTALL_DIR}/.git" remote set-url origin "$(autominer_source)" || {
        echo >&2 'Failed to add remote "origin" (or set the URL). Please report this!'
        exit 2
      }
      command git --git-dir="${INSTALL_DIR}/.git" fetch origin tag "$(autominer_latest_version)" --depth=1 || {
        echo >&2 'Failed to fetch origin with tags. Please report this!'
        exit 2
      }
    else
      command git clone "$(autominer_source)" -b "$(autominer_latest_version)" --depth=1 "${INSTALL_DIR}" || {
        echo >&2 'Failed to clone ethOS Autominer repo. Please report this!'
        exit 2
      }
    fi
  fi
  command git --git-dir="$INSTALL_DIR"/.git --work-tree="$INSTALL_DIR" checkout -f --quiet "$(autominer_latest_version)"
  if [ ! -z "$(command git --git-dir="$INSTALL_DIR"/.git --work-tree="$INSTALL_DIR" show-ref refs/heads/master)" ]; then
    if command git --git-dir="$INSTALL_DIR"/.git --work-tree="$INSTALL_DIR" branch --quiet 2>/dev/null; then
      command git --git-dir="$INSTALL_DIR"/.git --work-tree="$INSTALL_DIR" branch --quiet -D master >/dev/null 2>&1
    else
      echo >&2 "Your version of git is out of date. Please update it!"
      command git --git-dir="$INSTALL_DIR"/.git --work-tree="$INSTALL_DIR" branch -D master >/dev/null 2>&1
    fi
  fi

  echo "=> Compressing and cleaning up git repository"
  if ! command git --git-dir="$INSTALL_DIR"/.git --work-tree="$INSTALL_DIR" reflog expire --expire=now --all; then
    echo >&2 "Your version of git is out of date. Please update it!"
  fi
  if ! command git --git-dir="$INSTALL_DIR"/.git --work-tree="$INSTALL_DIR" gc --auto --aggressive --prune=now ; then
    echo >&2 "Your version of git is out of date. Please update it!"
  fi
  return
}

autominer_try_profile() {
  if [ -z "${1-}" ] || [ ! -f "${1}" ]; then
    return 1
  fi
  echo "${1}"
}

#
# Detect profile file if not specified as environment variable
# (eg: PROFILE=~/.myprofile)
# The echo'ed path is guaranteed to be an existing file
# Otherwise, an empty string is returned
#
autominer_detect_profile() {
  if [ -n "${PROFILE}" ] && [ -f "${PROFILE}" ]; then
    echo "${PROFILE}"
    return
  fi

  local DETECTED_PROFILE
  DETECTED_PROFILE=''
  local SHELLTYPE
  SHELLTYPE="$(basename "/$SHELL")"

  if [ "$SHELLTYPE" = "bash" ]; then
    if [ -f "$HOME/.bashrc" ]; then
      DETECTED_PROFILE="$HOME/.bashrc"
    elif [ -f "$HOME/.bash_profile" ]; then
      DETECTED_PROFILE="$HOME/.bash_profile"
    fi
  elif [ "$SHELLTYPE" = "zsh" ]; then
    DETECTED_PROFILE="$HOME/.zshrc"
  fi

  if [ -z "$DETECTED_PROFILE" ]; then
    for EACH_PROFILE in ".profile" ".bashrc" ".bash_profile" ".zshrc"
    do
      if DETECTED_PROFILE="$(autominer_try_profile "${HOME}/${EACH_PROFILE}")"; then
        break
      fi
    done
  fi

  if [ ! -z "$DETECTED_PROFILE" ]; then
    echo "$DETECTED_PROFILE"
  fi
}

autominer_do_install() {
  install_autominer_from_git

  echo

  local AUTOMINER_PROFILE
  AUTOMINER_PROFILE="$(autominer_detect_profile)"
  local PROFILE_INSTALL_DIR
  PROFILE_INSTALL_DIR="$(autominer_install_dir| sed "s:^$HOME:\$HOME:")"

  SOURCE_STR="\\nPATH=\"\$PATH:${PROFILE_INSTALL_DIR}\" # This loads ethOS Autominer\\n"
  #SOURCE_STR="\\nexport AUTOMINER_DIR=\"${PROFILE_INSTALL_DIR}\"\\n[ -s \"\$AUTOMINER_DIR/ethos-autominer\" ] && \\. \"\$AUTOMINER_DIR/ethos-autominer\"  # This loads ethOS Autominer\\n"
  # shellcheck disable=SC2016
  BASH_OR_ZSH=false

  if [ -z "${AUTOMINER_PROFILE-}" ] ; then
    local TRIED_PROFILE
    if [ -n "${PROFILE}" ]; then
      TRIED_PROFILE="${AUTOMINER_PROFILE} (as defined in \$PROFILE), "
    fi
    echo "=> Profile not found. Tried ${TRIED_PROFILE-}~/.bashrc, ~/.bash_profile, ~/.zshrc, and ~/.profile."
    echo "=> Create one of them and run this script again"
    echo "   OR"
    echo "=> Append the following lines to the correct file yourself:"
    command printf "${SOURCE_STR}"
  else
    BASH_OR_ZSH=true
    if ! command grep -qc '/ethos-autominer' "$AUTOMINER_PROFILE"; then
      echo "=> Appending ethOS Autominer source string to $AUTOMINER_PROFILE"
      command printf "${SOURCE_STR}" >> "$AUTOMINER_PROFILE"
    else
      echo "=> ethOS Autominer source string already in ${AUTOMINER_PROFILE}"
    fi
    # shellcheck disable=SC2016
  fi

  if ! command crontab -l | grep -qc '/ethos-autominer'; then
    echo "=> Appending ethOS Autominer to crontab"
    command crontab -l > autominer.cron && echo "* * * * * ${PROFILE_INSTALL_DIR}/ethos-autominer 2>&1 > /dev/null" >> autominer.cron && crontab autominer.cron && rm autominer.cron
    #command printf "${SOURCE_STR}" >> "$AUTOMINER_PROFILE"
  else
    echo "=> ethOS Autominer already in crontab"
  fi

  command ~/ethos-autominer --setup "${PROFILE_INSTALL_DIR}/"

  echo "=> Adding web dashboard server to start up, ethos user password required..."
  command sudo sed -i 's/exit 0/su - ethos -c "screen -dm -S web php -S 0.0.0.0:8080 -t \/home\/ethos\/ethos-autominer\/web\/"\n\nexit 0/' /etc/rc.local
  command screen -dm -S web php -S 0.0.0.0:8080 -t /home/ethos/ethos-autominer/web/

  # Source ethOS Autominer
  # shellcheck source=/dev/null
  #\. "$(autominer_install_dir)/ethos-autominer"

  autominer_reset

  #echo "=> Close and reopen your terminal to start using ethOS Autominer or run the following to use it now:"
  #command printf "${SOURCE_STR}"
}

#
# Unsets the various functions defined
# during the execution of the install script
#
autominer_reset() {
  unset -f autominer_has autominer_install_dir autominer_latest_version \
    autominer_source autominer_download install_autominer_from_git \
    autominer_try_profile autominer_detect_profile \
    autominer_do_install autominer_reset
}

[ "_$AUTOMINER_ENV" = "_testing" ] || autominer_do_install

} # this ensures the entire script is downloaded #
