# Notes
Data wrangling: take data in one format and turn it into a different format.

```bash
ssh myserver 'journalctl | grep sshd | grep "Disconnected from"' > ssh.logs
less ssh.log | sed 's/.*Disconnected from //'
```
- Do the filtering on the remote server, and then massage the data locally
- `less` gives us a “pager” that allows us to scroll up and down through the long output.
- use `sed` to edit the output.
  - `sed` is a “stream editor” that builds on top of the old `ed` editor.
  - you give short commands for how to modify the file, rather than manipulate its contents directly (although you can do that too).
  - `s/REGEX/SUBSTITUTION/` just likes vim

## Regular expressions
Exactly which characters do what vary somewhat between different implementations of regular expressions, which is a source of great frustration. Very common patterns are:
- `.` means “any single character” except newline
- `*` zero or more of the preceding match
- `+` one or more of the preceding match
- `[abc]` any one character of a, b, and c
- `(RX1|RX2)` either something that matches RX1 or RX2 (grouping also provides backreference)
- `^` the start of the line
- `$` the end of the line

sed’s regular expressions are somewhat weird, and will require you to put a `\` before most of these to give them their special meaning. Or you can pass `-E`.

`*` and `+` are, by default, “greedy”. They will match as much text as they can.
```
Jan 17 03:13:00 thesquareplanet.com sshd[2631]: Disconnected from invalid user Disconnected from 46.97.239.16 port 55920 [preauth]

46.97.239.16 port 55920 [preauth]
```

```bash
| sed -E 's/.*Disconnected from (invalid |authenticating )?user .* [^ ]+ port [0-9]+( \[preauth\])?$/\2/'
```
1. `(invalid |authenticating )?user` matches any of the “user” variants (there are two prefixes in the logs)
2. `.*` matches on any string of characters where the username is.
3. `[^ ]+` matches on any string with space as end ( `[^ ]`Match a single character not present in the list below).
4. `( \[preauth\])?$//` matches possibly the suffix `[preauth]`, and then the end of the line. (`?` zero or one occurrence)

- Regexp are not obvious, don't waste your time and use [debugger](https://regex101.com/)

## Data wrangling
```
ssh myserver journalctl
 | grep sshd
 | grep "Disconnected from"
 | sed -E 's/.*Disconnected from (invalid |authenticating )?user (.*) [^ ]+ port [0-9]+( \[preauth\])?$/\2/'
 | sort | uniq -c
```
- `sort` sorts its input in lexicographic (numeric and then in alphabetic).
- `uniq -c` will collapse consecutive lines that are the same into a single line
```
 | sort -nk1,1 | tail -n10
```
- `sort -n` will sort in numeric (instead of lexicographic) order.
- `-k1,1` means “sort by only the first whitespace-separated column”.
  - The `,n` part says “sort until the nth field, where the default is the end of the line.

## awk - another editor
`awk` is a programming language that just happens to be really good at processing text streams.
```bash
| awk '{print $2}' | paste -sd,
```
- `awk` programs take an optional pattern and a block 
- Block says what to do if the pattern matches a given line.
- The default pattern matches all lines.
- `$0` is set to the entire line’s contents, and `$1` through `$n` are set to the nth field of that line
- `awk` field separator is whitespace by default, can change with -F.
```bash
| awk '$1 == 1 && $2 ~ /^c[^ ]*e$/ { print $2 }' | wc -l
```
computes the number of single-use usernames that start with c and end with e.
```awk
BEGIN { rows = 0 }
$1 == 1 && $2 ~ /^c[^ ]*e$/ { rows += $1 }
END { print rows }
```
- BEGIN is a pattern that matches the start of the input.
- END matches the end.
- `{ rows = 0 }` defines a variable

## Analyzing data
You can do math directly in your shell using `bc`, a calculator that can read from STDIN!
```
| paste -sd+ | bc -l
```
add the numbers on each line together by concatenating them together, delimited by `+:`.
```
| awk '{print $1}' | R --slave -e 'x <- scan(file="stdin", quiet=TRUE); summary(x)'
```
R is another (weird) programming language that’s great at data analysis and [plotting](https://ggplot2.tidyverse.org/).
```
| gnuplot -p -e 'set boxwidth 0.5; plot "-" using 1:xtic(2) with boxes'
```
If you just want some simple plotting, `gnuplot` is your friend.

## Data wrangling to make arguments
`xargs` can be a powerful combo.
```bash
rustup toolchain list | grep nightly | grep -vE "nightly-x86" | sed 's/-x86.*//' | xargs echo rustup toolchain uninstall
```

## Wrangling binary data
```bash
ffmpeg -loglevel panic -i /dev/video0 -frames 1 -f image2 -
 | convert - -colorspace gray -
 | gzip
 | ssh mymachine 'gzip -d | tee copy.jpg | env DISPLAY=:0 feh -'
```
- `-i /dev/video0` uses webcam on the computer
- `-frame 1` takes the first frame
- `-f image2` takes an image instead of single frame video file
- `-` dash is an usual way you tell the program to use STDIN/OUT
  - `convert - -colorspace gray -` first dash indicates STDIN, second indicates STDOUT
- `tee copy.jpg` will take STDIN to file `copy.jpg`, and also prints STDOUT.

## Extra
### Lookahead and Lookbehind Zero-Length Assertions
Just like `\b`,  they do not consume characters in the string, but only assert whether a match is possible or not.
- Positive and Negative Lookahead `(?=(regex))` `(?!(regex))`. `q(?!u).` matches a q not followed by a u.
- Positive and Negative Lookbehind `(?<=(regex))` `(?<!(regex)).` `(?<!a)b` matches a “b” that is not preceded by an “a”

## Lecture Highlight
- [22:21](https://youtu.be/sz_dsktIjt4?t=1341) inject attack
- [27:00](https://youtu.be/sz_dsktIjt4?t=1632) the most correct way to parse email. (You should use a better way to understand it)

# Excercise
- Take this [short interactive regex tutorial](https://regexone.com/).
- To do in-place substitution it is quite tempting to do something like `sed s/REGEX/SUBSTITUTION/ input.txt > input.txt`. However this is a bad idea, why? Is this particular to sed? Use man sed to find out how to accomplish this.
  - The programs in pipelines are executed in parallel. `> input.txt` will create a blank input.txt file before `sed` so if the `-i` is missing in sed, sed will not replace the blank `input.txt` with the one has the output.
  - Is not particular to `sed`. Most programs don't allow in-place editing by default.
- Find an online data set like this one, this one, or maybe one from here. Fetch it using curl and extract out just two columns of numerical data. If you’re fetching HTML data, pup might be helpful. For JSON data, try jq. Find the min and max of one column in a single command, and the difference of the sum of each column in another.
  - If you’re fetching HTML data, [pup](https://github.com/EricChiang/pup) might be helpful. For JSON data, try [jq](https://stedolan.github.io/jq/). 