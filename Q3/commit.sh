#!/bin/bash

csv_location="data.csv"

[ -f "$csv_location" ] || { echo "CSV file $csv_location is missing!"; exit 1; }

current_branch=$(git branch --show-current)

branch_data=$(awk -F, -v br="$current_branch" '$3==br {print}' "$csv_location")

[ -n "$branch_data" ] || { echo "No entry for branch $current_branch in CSV!"; exit 1; }

bug_id=$(cut -d',' -f1 <<< "$branch_data")
desc=$(cut -d',' -f2 <<< "$branch_data")
priority_level=$(cut -d',' -f5 <<< "$branch_data")
dev_name=$(cut -d',' -f4 <<< "$branch_data")
repo_path=$(cut -d',' -f6 <<< "$branch_data")
github_link=$(cut -d',' -f7 <<< "$branch_data")

timestamp=$(date '+%Y-%m-%d %H:%M:%S')

commit_msg="${bug_id}:${timestamp}:${current_branch}:${dev_name}:${priority_level}:${desc}"

[ -n "$1" ] && commit_msg="${commit_msg}:${1}"

git add .

git commit -m "$commit_msg"

git push origin "$current_branch"

[ $? -eq 0 ] && echo "Successfully committed and pushed!" || { echo "Failed to commit or push!"; exit 1; }
