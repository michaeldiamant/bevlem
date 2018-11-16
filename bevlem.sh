#!/bin/bash

declare -a tracked_repos=(
  "akashi"
  "ansible"
  "drumheller"
  "helix"
  "hellgate"
  "hellgate-external"
  "k2"
  "kootenai"
  "goldengate"
  "ota"
  "ota-external"
  "pierre"
  "silvergate"
  "threedollar"
  "vasco")

# Inspired by https://stackoverflow.com/a/17841619.
function join_by {
  local d=$1
  shift; echo -n "$1"
  shift
  printf "%s" "${@/#/$d}"
}

declare -a ops=(
  "length,0,PR_Count"
  "min,N/A,Min_Days"
  "max,N/A,Max_Days"
  "add/length,N/A,Mean_Days")

function compute_pr_stats {
  local input_file="${1}"
  local temp_file="${2}"
  local prs=$(
    cat "${input_file}" | 
    jq -r '.[] | .created_at' | \
    xargs -L1 -I {} \
      python -c 'from datetime import datetime; \
                 now = datetime.utcnow(); \
                 created = datetime.strptime("{}", "%Y-%m-%dT%H:%M:%SZ"); \
                 print ((now - created).days)')
  local length=$(echo ${prs} | jq -s length)
  if [ ${length} -eq 0 ]; then
    for i in "${ops[@]}"; do IFS=","; set -- $i; printf "%s " "${2}" >> "${temp_file}"; done
  else
     for i in "${ops[@]}"; do IFS=","; set -- $i; printf "%s " "$(echo ${prs} | jq -s ${1})" >> "${temp_file}"; done
  fi
  printf "\n" >> "${temp_file}"
}

function run {
  local token="${1}"
  local use_local_cache="${2}"
  local beginning_repos=("${tracked_repos[@]/#/^}")
  local exact_repos=("${beginning_repos[@]/%/$}")
  local repos_header_file="/tmp/repos_header.txt"
  local repos_file="/tmp/repos.txt"

  if [ "${use_local_cache}" = false ]; then
    # Inspired by https://gist.github.com/michfield/4525251
    curl -sI \
      --header "Authorization: token ${token}" \
      https://api.github.com/orgs/ntoggle/repos > "${repos_header_file}"
    last_page=$(cat "${repos_header_file}" | sed -nr 's/^Link:.*page=([0-9]+)>; rel="last".*/\1/p')
    rm -f "${repos_file}"
    for page in $(seq 1 "${last_page}");
      do
        curl -s \
          --header "Authorization: token ${token}" https://api.github.com/orgs/ntoggle/repos?page="${page}" >> "${repos_file}"
      done
  fi

  local repos=$(
    cat "${repos_file}" |
    jq -r '.[] | .name' |
    grep -E "$(join_by '|' "${exact_repos[@]}")" | 
    sort)
  
  local temp_file="/tmp/out.tmp"

  printf "Repo " >> "${temp_file}"
  for i in "${ops[@]}"; do IFS=","; set -- $i; printf "%s " "${3}" >> "${temp_file}"; done
  unset IFS
  printf "\n" >> "${temp_file}"

  for repo in ${repos};
  do
    input_file="/tmp/prs_${repo}.txt"
    printf "%s " "${repo}" >> "${temp_file}"
    if [ "${use_local_cache}" = false ]; then
      curl -s --header "Authorization: token ${token}" \
        https://api.github.com/repos/nToggle/${repo}/pulls > "${input_file}"
    fi
    compute_pr_stats "${input_file}" "${temp_file}"
  done

  column -ts" " "${temp_file}"
  rm -f "${temp_file}"
}

token=${1?"Specify Github API token"}
use_local_cache=${2:-false}

run "${token}" "${use_local_cache}"

