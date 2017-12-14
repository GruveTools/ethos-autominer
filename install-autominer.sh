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
  if [ "_$AUTOMINER_METHOD" = "_script-autominer-exec" ]; then
    AUTOMINER_SOURCE_URL="https://raw.githubusercontent.com/creationix/nvm/$(autominer_latest_version)/nvm-exec"
  elif [ "_$AUTOMINER_METHOD" = "_script-autominer-bash-completion" ]; then
    AUTOMINER_SOURCE_URL="https://raw.githubusercontent.com/creationix/nvm/$(autominer_latest_version)/bash_completion"
  elif [ -z "$AUTOMINER_SOURCE_URL" ]; then
    if [ "_$AUTOMINER_METHOD" = "_script" ]; then
      AUTOMINER_SOURCE_URL="https://raw.githubusercontent.com/creationix/nvm/$(autominer_latest_version)/nvm.sh"
    elif [ "_$AUTOMINER_METHOD" = "_git" ] || [ -z "$AUTOMINER_METHOD" ]; then
      AUTOMINER_SOURCE_URL="https://github.com/Japh/ethos-autominer.git"
    else
      echo >&2 "Unexpected value \"$AUTOMINER_METHOD\" for \$AUTOMINER_METHOD"
      return 1
    fi
  fi
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

install_autominer_as_script() {
  local INSTALL_DIR
  INSTALL_DIR="$(autominer_install_dir)"
  local AUTOMINER_SOURCE_LOCAL
  AUTOMINER_SOURCE_LOCAL="$(autominer_source script)"
  local AUTOMINER_EXEC_SOURCE
  AUTOMINER_EXEC_SOURCE="$(autominer_source script-autominer-exec)"
  local AUTOMINER_BASH_COMPLETION_SOURCE
  AUTOMINER_BASH_COMPLETION_SOURCE="$(autominer_source script-autominer-bash-completion)"

  # Downloading to $INSTALL_DIR
  mkdir -p "$INSTALL_DIR"
  if [ -f "$INSTALL_DIR/nvm.sh" ]; then
    echo "=> ethOS Autominer is already installed in $INSTALL_DIR, trying to update the script"
  else
    echo "=> Downloading ethOS Autominer as script to '$INSTALL_DIR'"
  fi
  autominer_download -s "$AUTOMINER_SOURCE_LOCAL" -o "$INSTALL_DIR/nvm.sh" || {
    echo >&2 "Failed to download '$AUTOMINER_SOURCE_LOCAL'"
    return 1
  } &
  autominer_download -s "$AUTOMINER_EXEC_SOURCE" -o "$INSTALL_DIR/nvm-exec" || {
    echo >&2 "Failed to download '$AUTOMINER_EXEC_SOURCE'"
    return 2
  } &
  autominer_download -s "$AUTOMINER_BASH_COMPLETION_SOURCE" -o "$INSTALL_DIR/bash_completion" || {
    echo >&2 "Failed to download '$AUTOMINER_BASH_COMPLETION_SOURCE'"
    return 2
  } &
  for job in $(jobs -p | sort)
  do
    wait "$job" || return $?
  done
  chmod a+x "$INSTALL_DIR/nvm-exec" || {
    echo >&2 "Failed to mark '$INSTALL_DIR/nvm-exec' as executable"
    return 3
  }
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

#
# Check whether the user has any globally-installed npm modules in their system
# Node, and warn them if so.
#
autominer_check_global_modules() {
  command -v npm >/dev/null 2>&1 || return 0

  local NPM_VERSION
  NPM_VERSION="$(npm --version)"
  NPM_VERSION="${NPM_VERSION:--1}"
  [ "${NPM_VERSION%%[!-0-9]*}" -gt 0 ] || return 0

  local NPM_GLOBAL_MODULES
  NPM_GLOBAL_MODULES="$(
    npm list -g --depth=0 |
    command sed -e '/ npm@/d' -e '/ (empty)$/d'
  )"

  local MODULE_COUNT
  MODULE_COUNT="$(
    command printf %s\\n "$NPM_GLOBAL_MODULES" |
    command sed -ne '1!p' |                     # Remove the first line
    wc -l | tr -d ' '                           # Count entries
  )"

  if [ "${MODULE_COUNT}" != '0' ]; then
    # shellcheck disable=SC2016
    echo '=> You currently have modules installed globally with `npm`. These will no'
    # shellcheck disable=SC2016
    echo '=> longer be linked to the active version of Node when you install a new node'
    # shellcheck disable=SC2016
    echo '=> with `nvm`; and they may (depending on how you construct your `$PATH`)'
    # shellcheck disable=SC2016
    echo '=> override the binaries of modules installed with `nvm`:'
    echo

    command printf %s\\n "$NPM_GLOBAL_MODULES"
    echo '=> If you wish to uninstall them at a later point (or re-install them under your'
    # shellcheck disable=SC2016
    echo '=> `nvm` Nodes), you can remove them from the system Node as follows:'
    echo
    echo '     $ nvm use system'
    echo '     $ npm uninstall -g a_module'
    echo
  fi
}

autominer_do_install() {
  if [ -z "${METHOD}" ]; then
    # Autodetect install method
    if autominer_has git; then
      install_autominer_from_git
    elif autominer_has autominer_download; then
      install_autominer_as_script
    else
      echo >&2 'You need git, curl, or wget to install ethOS Autominer'
      exit 1
    fi
  elif [ "${METHOD}" = 'git' ]; then
    if ! autominer_has git; then
      echo >&2 "You need git to install ethOS Autominer"
      exit 1
    fi
    install_autominer_from_git
  elif [ "${METHOD}" = 'script' ]; then
    if ! autominer_has autominer_download; then
      echo >&2 "You need curl or wget to install ethOS Autominer"
      exit 1
    fi
    install_autominer_as_script
  fi

  echo

  local AUTOMINER_PROFILE
  AUTOMINER_PROFILE="$(autominer_detect_profile)"
  local PROFILE_INSTALL_DIR
  PROFILE_INSTALL_DIR="$(autominer_install_dir| sed "s:^$HOME:\$HOME:")"

  SOURCE_STR="\\nexport AUTOMINER_DIR=\"${PROFILE_INSTALL_DIR}\"\\n[ -s \"\$AUTOMINER_DIR/nvm.sh\" ] && \\. \"\$AUTOMINER_DIR/nvm.sh\"  # This loads ethOS Autominer\\n"
  # shellcheck disable=SC2016
  COMPLETION_STR='[ -s "$AUTOMINER_DIR/bash_completion" ] && \. "$AUTOMINER_DIR/bash_completion"  # This loads ethOS Autominer bash_completion\n'
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
    if ! command grep -qc '/nvm.sh' "$AUTOMINER_PROFILE"; then
      echo "=> Appending ethOS Autominer source string to $AUTOMINER_PROFILE"
      command printf "${SOURCE_STR}" >> "$AUTOMINER_PROFILE"
    else
      echo "=> ethOS Autominer source string already in ${AUTOMINER_PROFILE}"
    fi
    # shellcheck disable=SC2016
    if ${BASH_OR_ZSH} && ! command grep -qc '$AUTOMINER_DIR/bash_completion' "$AUTOMINER_PROFILE"; then
      echo "=> Appending bash_completion source string to $AUTOMINER_PROFILE"
      command printf "$COMPLETION_STR" >> "$AUTOMINER_PROFILE"
    else
      echo "=> bash_completion source string already in ${AUTOMINER_PROFILE}"
    fi
  fi
  if ${BASH_OR_ZSH} && [ -z "${AUTOMINER_PROFILE-}" ] ; then
    echo "=> Please also append the following lines to the if you are using bash/zsh shell:"
    command printf "${COMPLETION_STR}"
  fi

  # Source nvm
  # shellcheck source=/dev/null
  \. "$(autominer_install_dir)/nvm.sh"

  autominer_check_global_modules

  autominer_reset

  echo "=> Close and reopen your terminal to start using ethOS Autominer or run the following to use it now:"
  command printf "${SOURCE_STR}"
  if ${BASH_OR_ZSH} ; then
    command printf "${COMPLETION_STR}"
  fi
}

#
# Unsets the various functions defined
# during the execution of the install script
#
autominer_reset() {
  unset -f autominer_has autominer_install_dir autominer_latest_version \
    autominer_source autominer_download install_autominer_from_git \
    install_autominer_as_script autominer_try_profile autominer_detect_profile autominer_check_global_modules \
    autominer_do_install autominer_reset
}

[ "_$AUTOMINER_ENV" = "_testing" ] || autominer_do_install

} # this ensures the entire script is downloaded #
