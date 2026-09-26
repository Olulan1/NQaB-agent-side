#!/bin/sh
printf '\033c\033]0;%s\a' NQAB
base_path="$(dirname "$(realpath "$0")")"
"$base_path/NQaB.x86_64" "$@"
