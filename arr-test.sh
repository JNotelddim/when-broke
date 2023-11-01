#!/usr/bin/env bash

# Array operations tests
# I'm current struggling to get a subset of an array based on a dynamic index...
# The substring Expansion ${string:<start>:<count>} notation doesn't seem to be allowing for me to use variables in the <start> and <count> positions?

arr=('cat' 'dog' 'mouse' 'bird' 'koala' 'kangaroo' 'frog' 'raven' 'eel' 'bear' 'hummingbird' 'human')
echo "$arr"


found=false
i=0
workingArr=("${arr[@]}")  
printf '%s\n' "${workingArr[@]}"

while [[ $found == false && i -lt 10 ]]; do
    # bash uses floor rounding natively
    numItems=${#workingArr[@]}
    midItemIndex=$(( $numItems / 2 ))
    midItem=${workingArr[$midItemIndex]}

    echo $'\n'"[$i]; workingArrCount: ${#workingArr[*]}; midIndex: $midItemIndex; midItem: $midItem"
    matches=($midItem == "dog")

    if [ $matches == true ]; then
        echo "[matches] Go further forward."
        # Re-assing working array to be 'mid' => [-1]
        workingArr=("${workingArr[@]:$midItemIndex}")
        echo "New Working Array based on midItemIndex: $midItemIndex, num items: ${#workingArr[*]}"
        printf '%s\n' "${workingArr[@]}"
    else
        echo "[Not matches] Go further back."
        # Re-assign working array to be 0 => 'mid'
        workingArr=("${workingArr[@]::$midItemIndex}")
        echo "New Working Array based on midItemIndex: $midItemIndex, num items: ${#workingArr[*]}"
        printf '%s\n' "${workingArr[@]}"
    fi

    i=$(( i + 1 ))
done
