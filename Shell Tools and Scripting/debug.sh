#!/usr/bin/env zsh
count=0
until [[ "$?" -ne 0 ]]; # you need qoute it to expand the var
do
	((count++)) # arithmetic expansion
	./"$1" &> log.txt
done

echo "total execution times: $count"
cat log.txt
