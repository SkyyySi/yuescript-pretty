#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname -- "$(realpath --physical -- "${BASH_SOURCE[0]}")")" || exit 1

clear

unset LUA_PATH LUA_CPATH
eval "$(luarocks path --lua-version='5.4')"

printf '>>> Watching for changes to .yue files in %q...\n' "$PWD"

declare file=''
declare file_relative=''
while true; do
	file=$(inotifywait --quiet --recursive --event='modify' --format='%w/%f' --include='.*\.yue' -- './pretty/')
	file_relative=$(realpath --relative-base="$PWD" -- "$file")

	clear

	printf '\e[0m>>> File: %q\n' "$file_relative"
	printf '\e[2m%*s\e[0m\n' "$(( ${COLUMNS:-$(tput cols)} - 1 ))" ' ' | sed -- 's/ /─/g'

	if ! yue -e "$file_relative"; then
		printf '\e[0m>>> Exit code: \e[1;31m%d\e[0m\n' "$?"
	fi
done
