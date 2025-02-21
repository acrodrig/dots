# Make sure that Mac OS X does not alert us on shell change
# Make sure that Mac OS X does not alert us on shell change
export BASH_SILENCE_DEPRECATION_WARNING=1

# ----------------------------------------------------------------------------
# BASICS
# ----------------------------------------------------------------------------

# Colors - declare them to make it easier to use
COLOR_DEFAULT="\[\033[m\]"
COLOR_RED="\[\033[31m\]"
COLOR_GREEN="\[\033[32m\]"
COLOR_YELLOW="\[\033[33m\]"
COLOR_BLUE="\[\033[34m\]"
COLOR_PURPLE="\[\033[35m\]"
COLOR_CYAN="\[\033[36m\]"
COLOR_LIGHTGRAY="\[\033[37m\]"
COLOR_DARKGRAY="\[\033[1;30m\]"
COLOR_LIGHTRED="\[\033[1;31m\]"
COLOR_LIGHTGREEN="\[\033[1;32m\]"
COLOR_LIGHTYELLOW="\[\033[1;33m\]"
COLOR_LIGHTBLUE="\[\033[1;34m\]"
COLOR_LIGHTPURPLE="\[\033[1;35m\]"
COLOR_LIGHTCYAN="\[\033[1;36m\]"
COLOR_WHITE="\[\033[37m\]"
COLOR_BG_BLACK="\[\033[40m\]"
COLOR_BG_RED="\[\033[41m\]"
COLOR_BG_GREEN="\[\033[42m\]"
COLOR_BG_YELLOW="\[\033[43m\]"
COLOR_BG_BLUE="\[\033[44m\]"
COLOR_BG_PURPLE="\[\033[45m\]"
COLOR_BG_CYAN="\[\033[46m\]"
COLOR_BG_LIGHTGRAY="\[\033[47m\]"

# Simple Prompt as shown below with different colors for each concept
# <full-dir> (<git-branch>) $
git_branch() { git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ (\1)/'; }
export PS1="$COLOR_CYAN\w$COLOR_YELLOW\$(git_branch)$COLOR_WHITE \$$COLOR_DEFAULT "

# History - ignore duplicates, and very long history (as to not forget)
export HISTCONTROL=ignoreboth:erasedups
export HISTSIZE=10000
function h() { history | grep ${1:-.}; }

# Append to the history file, don't overwrite it (see sensible bash at https://github.com/mrzool/bash-sensible)
shopt -s histappend

# Save multi-line commands as one command (see sensible bash at https://github.com/mrzool/bash-sensible)
shopt -s cmdhist

# Perform file completion in a case insensitive fashion (see sensible bash at https://github.com/mrzool/bash-sensible)
bind "set completion-ignore-case on"

# Display matches for ambiguous patterns at first tab press (see sensible bash at https://github.com/mrzool/bash-sensible)
bind "set show-all-if-ambiguous on"

# Load private variables (Mac OS X does not load `.secrets` by default)
[ -r ~/.secrets ] && source ~/.secrets


# ----------------------------------------------------------------------------
# ALIAS
# ----------------------------------------------------------------------------

# Git Aliases for quick use (inspired by http://mjk.space/git-aliases-i-cant-live-without/)
alias gb="git checkout"
alias gc="git commit -m"
alias gp="git push"
alias gr="git pull --rebase"
alias gs="git status"
alias gf="git fetch --all"

# Alias for deno
alias dt="deno task"

# Alias for screen
alias sl="screen -ls"
alias sr="screen -r"
alias sx="screen -x"
alias ss="screen -S"

# Set up quick IntelliJ opening from the command line
alias idea='open -na "IntelliJ IDEA.app" --args "$@"'

# Script to release to github
alias release="$HOME/Code/AC/dots/scripts/release.ts"


# ----------------------------------------------------------------------------
# UTILITIES
# ----------------------------------------------------------------------------

# search/hunt
# Small function(s) to search text in code from the command line without remembering grep options
# `search` searches all files and displays matching lines
# `hunt` searches all files and displays only the name of the file containing the match
function search() { grep --color -I --exclude-dir={node_modules,dist,external,docs,_site,.git,out} -r "$1" *; }
function hunt() { grep -I -l --exclude-dir={node_modules,dist,external,docs,_site,.git,out} -r "$1" *; }

# fpd for "Fix Photo(s) Date(s)"
# Change dates based on EXIF creation date (works using Mac OS X utility `mdls` and `date`), can be invoked for a single
# file (fpd IMAGE.JSP) or all files in directory (fpd *)
function fpd() {
    [ ! -f $1 ] && echo "usage: fpd <file1> <file2> ... <fileN>" && return 1

    dc="\033[m"
    wc="\033[37m"
    for f in $@; do
        udt=$(mdls $f | awk -F' *= *' '/kMDItemContentCreationDate / { print $2 }')
        ldt=$(date -j -f "%Y-%m-%d %H:%M:%S %z" "$udt" "+%Y-%m-%d %H:%M:%S")
        tdt=$(date -j -f "%Y-%m-%d %H:%M:%S %z" "$udt" "+%Y%m%d%H%M.%S")
        echo -e Fixing $wc$f$dc date to $wc$ldt$dc
        touch -cmt $tdt $f
    done
}

# Resize terminal width/height
function ts() { printf "\e[8;${2:-64};${1:-256}t"; }

# Open terminals the way I like it (should install via Automator)
# See https://apple.stackexchange.com/questions/175215/how-do-i-assign-a-keyboard-shortcut-to-an-applescript-i-wrote
function terms() {
    osascript -l JavaScript -e "Application('Terminal').doScript('ts 132 && clear')"
    osascript -l JavaScript -e "Application('Terminal').doScript('ts 256 && clear')"
    osascript -l JavaScript -e "Application('Terminal').doScript('ts 256 && clear')"
}

# Git Un tag
function untag() {
    git tag -d $1 && git push origin --delete $1
}

# Refresh Chrome
function refresh-chrome() {
    osascript -e 'tell application "Chrome" to tell the active tab of its first window to reload'
}

# Echoes GitHub
# see https://stackoverflow.com/questions/12082981/get-all-git-commits-since-last-tag
function notes() {
    git log $(git describe --tags --abbrev=0)..HEAD --oneline --no-decorate
}

# List versions of package
# curl -s -L -H "Authorization: Bearer $GITHUB_PAT" "https://api.github.com/.../versions" | jq -r .[].name
function versions() {
    URL=$(git config --get remote.origin.url)
    REPO=${1:-$(basename -s .git $URL)}
    gh api /users/$1/packages/container/$2/versions | jq -r .[].version
}

function et() {
    exiftool -json $1 | jq -r '.[0].ImageDescription' | tee >(pbcopy)
}


# ----------------------------------------------------------------------------
# OTHER
# ----------------------------------------------------------------------------

# Add quick directory changing to code
export PATH="/Users/andres/.deno/bin:$PATH"
export CDPATH=.:~/Code/AC:~/Code/RC
