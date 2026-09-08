#!/bin/bash

#This comment added from GitHub

analysis_file="$HOME/analysisData.log"
summary_file="$HOME/summary.log"

# (Step 1) Check for number of provided arguments.
if [ "$#" -eq 0 ]; then
    dir="$(pwd)"
elif [ "$#" -eq 1 ]; then
    if [ -d "$1" ]; then
        dir="$1"
    else
        echo -e "usage: arg needs to be a directory.\n"
        exit 1
    fi
else
    echo -e "usage: more than 1 arg is not allowed.\n"
    exit 2
fi

dir="$(cd "$dir" && pwd)"

# (Step 2)Only find log files which were modified within the last 7 days.
mapfile -t log_files < <(find "$dir" -mindepth 1 -maxdepth 1 -type f \( -iname "*.log" -o -iname "syslog" \) -mtime -7)

num_files="${#log_files[@]}"

# (Step 3a) In the general case, if no log file is found that satisfies the provided 
# criteria and in the provided location, then the program should exit immediately.
if [ "$num_files" -eq 0 ]; then
    echo -e "No. of modified log files: 0\n"
    exit 0
fi

# (Step 3b) In the general case, if one or more log files are found, then for each file 
# we want to find and count how many errors (case insensitive) are there.
: > "$analysis_file"
: > "$summary_file"

sep_stars="********************"
sep_dashes="---------------------"

total_errors=0
max_errors=-1
max_file=""

for f in "${log_files[@]}"; do
    count=$(grep -ic "error" "$f")
    [ -z "$count" ] && count=0
    
    entry="Filename: $f <No. of errors found = $count>"

    echo "$sep_stars"
    echo "$entry"

    {
        echo "$sep_stars"
        echo "$entry"
    } >> "$analysis_file"

    total_errors=$((total_errors + count))
    if [ "$count" -gt "$max_errors" ]; then
        max_errors="$count"
        max_file="$f"
    fi
done

if [ "${#log_files[@]}" -eq 0 ]; then
    max_errors=0
fi

echo "$sep_dashes"
echo "Total errors found:$total_errors"
echo "File with the max errors: $max_file, <error-count:$max_errors>"

{
    echo "Total errors found:$total_errors"
    echo "File with the max errors: $max_file, <error-count:$max_errors>"
} >> "$summary_file"
