#!/usr/bin/env bash

CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

source "$CURRENT_DIR/helpers.sh"

gram_percentage_format="%3.1f%%"

print_gram_percentage() {
  gram_percentage_format=$(get_tmux_option "@gram_percentage_format" "$gram_percentage_format")

  if command_exists "nvidia-smi"; then
    loads=$(cached_eval nvidia-smi | sed -nr 's/.*\s([0-9]+)MiB\s*\/\s*([0-9]+)MiB.*/\1 \2/p')
  elif command_exists "cuda-smi"; then
    loads=$(cached_eval cuda-smi | sed -nr 's/.*\s([0-9.]+) of ([0-9.]+) MB.*/\1 \2/p' | awk '{print $2-$1" "$2}')
  elif command_exists "rocm-smi"; then
    echo $(cached_eval rocm-smi | sed -nr '6p' | awk '{ print $9 }')
  else
    echo "No GPU"
    return
  fi
  echo "$loads" | awk -v format="$gram_percentage_format" '{used+=$1; tot+=$2} END {printf format, 100*$1/$2}'
}

main() {
  print_gram_percentage
}
main
