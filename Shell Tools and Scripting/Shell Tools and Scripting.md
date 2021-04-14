# Notes
## Shell Scripting
- To assign variables, use the syntax `foo=bar` and access the value of the variable with `$foo`.
  - `foo = bar` will not work since it is interpreted as calling the `foo` *program* with arguments `=` and `bar`.
- `'` and `"` delimiters are not equivalent.
  - Strings delimited with `'` are literal strings and will not substitute variable values whereas `"` delimited strings will.
```bash
foo=bar
echo "$foo"
# prints bar
echo '$foo'
# prints $foo
```
- Special variables
  - `$0` - Name of the script
  - `$1` to `$9` - Arguments to the script. $1 is the first argument and so on.
  - `$@` - All the arguments
  - `$#` - Number of arguments 
  - `$?` - Return code of the previous command 
  - `$$` - Process identification number (PID) for the current script
  - `!!` - Entire last command, including arguments. A common pattern is to execute a command only for it to fail due to missing permissions; you can quickly re-execute the command with sudo by doing `sudo !!`
  - `$_` - Last argument from the last command. If you are in an interactive shell, you can also quickly get this value by typing `Esc` followed by `.`

```bash
#!/bin/bash

echo "Starting program at $(date)" # Date will be substituted

echo "Running program $0 with $# arguments with pid $$"

for file in "$@"; do
    grep foobar "$file" > /dev/null 2> /dev/null
    # When pattern is not found, grep has exit status 1
    # We redirect STDOUT and STDERR to a null register since we do not care about them
    if [[ $? -ne 0 ]]; then
        echo "File $file does not have any foobar, adding one"
        echo "# foobar" >> "$file"
    fi
done
```

- Commands will often return output using `STDOUT`, errors through `STDERR`, to communicate how execution went.
  - 0 - Okey; others - some errors occurred.
- Exit codes can be used to conditionally execute commands using `&&` and `||`
- Commands can also be separated within the same line using a semicolon `;`. 
- The `true` program will always have a 0 return code and the `false` command will always have a 1 return code.
```bash
false || echo "Oops, fail"
# Oops, fail

true || echo "Will not be printed"
#

true && echo "Things went well"
# Things went well

false && echo "Will not be printed"
#

true ; echo "This will always run"
# This will always run

false ; echo "This will always run"
# This will always run
```

- `$( CMD )` gets the output of a command as a variable. E.g., `for file in $(ls)`
  -  `<( CMD )` will also place the output in a temporary file. `diff <(ls foo) <(ls bar)`
- Use `[[ ]]` instead of `[]`, although you can use it in `sh`. Check [here](http://mywiki.wooledge.org/BashFAQ/031).
- *globbing:* Expanding expressions by carrying out filename expansion
  - Wildcards           - `?`(single character) and `*`(any)
  - Curly braces `{}`   - for loop
```bash
convert image.{png,jpg}
# Will expand to
convert image.png image.jpg

cp /path/to/project/{foo,bar,baz}.sh /newpath
# Will expand to
cp /path/to/project/foo.sh /path/to/project/bar.sh /path/to/project/baz.sh /newpath

# Globbing techniques can also be combined
mv *{.py,.sh} folder
# Will move all *.py and *.sh files


mkdir foo bar
# This creates files foo/a, foo/b, ... foo/h, bar/a, bar/b, ... bar/h
touch {foo,bar}/{a..h}
touch foo/x bar/y
# Show differences between files in foo and bar
diff <(ls foo) <(ls bar)
# Outputs
# < x
# ---
# > y
```

- There are tools like [shellcheck](https://github.com/koalaman/shellcheck) that will help you find errors in your sh/bash scripts.
- Use shebang to indicate interpreter.
- Use env to increase portability
```py
#!/usr/bin/env python |insteand of| #!/usr/local/bin/python
import sys
for arg in reversed(sys.argv[1:]):
    print(arg)
```
- Differences between shell functions and scripts
  - Functions have to be in the same language as the shell, while scripts can be written in any language. This is why including a shebang for scripts is important.
  - Functions are loaded once when their definition is read. Scripts are loaded every time they are executed. This makes functions slightly faster to load, but whenever you change them you will have to reload their definition.
  - Functions are executed in the current shell environment whereas scripts execute in their own process. Thus, functions can modify environment variables, e.g. change your current directory, whereas scripts can’t. Scripts will be passed by value environment variables that have been exported using `export` ?
  - As with any programming language, functions are a powerful construct to achieve modularity, code reuse, and clarity of shell code. Often shell scripts will include their own function definitions.

## Shell Tools
### Finding how to use commands
In most cases, except google it, you can use `command -h/--help` or `man command` to use your cognitive effort to figure out how the command works. It's a manual wrote by the developer.

[TLDR pages](https://tldr.sh/) are a nifty complementary solution that focuses on giving example use cases of a command so you can quickly figure out which options to use.

### Finding files
All UNIX-like systems come packaged with `find`, a great shell tool to find files.
```bash
# Find all directories named src
find . -name src -type d
# Find all python files that have a folder named test in their path
find . -path '*/test/*.py' -type f
# Find all files modified in the last day
find . -mtime -1
# Find all zip files with size in range 500k to 10M
find . -size +500k -size -10M -name '*.tar.gz'
# Delete all files with .tmp extension
find . -name '*.tmp' -exec rm {} \;
# Find all PNG files and convert them to JPG
find . -name '*.png' -exec convert {} {}.jpg \;
```
`find` and `fd` (fd-find)
```bash
find -name '*PATTERN*' # or -iname to be case insensitive
fd PATTERN
```
`locate` uses a database that is updated using [`updatedb`](https://www.man7.org/linux/man-pages/man1/updatedb.1.html). In most systems, `updatedb` is updated daily via [`cron`](https://www.man7.org/linux/man-pages/man8/cron.8.html). Therefore one trade-off between the two is speed vs freshness.

[find locate comparsion](https://unix.stackexchange.com/questions/60205/locate-vs-find-usage-pros-and-cons-of-each-other)

### Finding code
To search for all files that contain some pattern, along with where in those files said pattern occurs, most UNIX-like systems provide grep, a generic tool for matching patterns from the input text.
  - `-C` for getting **C**ontext around the matching line. `grep -C 5` will print 5 lines before and after the match.
  - `-v` for inverting the match. Print all lines that do not match the pattern.
  - `-R` since it will Recursively go into directories and look for files for the matching string.

ripgrep (`rg`) is a fast and intuitive alternative. Some examples:
```bash
# Find all python files where I used the requests library
rg -t py 'import requests'
# Find all files (-u including hidden files) without a shebang line
rg -u --files-without-match "^#!"
# Find all matches of foo and print the following 5 lines
rg foo -A 5
# Print statistics of matches (# of matched lines and files )
rg --stats PATTERN
```

>As with find/fd, it is important that you know that these problems can be quickly solved using one of these tools, while the specific tools you use are not as important.

### Finding shell commands
- The `history` command will let you access your shell history programmatically.
  - `history | grep find`
- Use `Ctrl+R` to perform backwards search through your history.
  - use [fzf](https://github.com/junegunn/fzf#using-git) to fly (install it with git)
- *history-based autosuggestions*
  - For [oh-my-zsh](https://github.com/zsh-users/zsh-autosuggestions/blob/master/INSTALL.md#oh-my-zsh) (plugins use whitespace to delimit parameters)

### Directory Navigation
- Create symlinks `ln -s`
- Jump to recently used directories
  - [`fasd`](https://github.com/clvv/fasd) ranks files and directories by frecency (frequency and recency)
  - [`autojump`](https://github.com/wting/autojump)
- Structured directory view: [`broot`](https://github.com/Canop/broot)

# Exercises
- Read `man ls` and write an `ls` command that lists files in the following manner
  - Includes all files, including hidden files -a
  - Sizes are listed in human readable format (e.g. 454M instead of 454279954) -h
  - Files are ordered by recency -t
  - Output is colorized --color=always
  - A sample output would look like this
```bash
-rw-r--r--   1 user group 1.1M Jan 14 09:53 baz
drwxr-xr-x   5 user group  160 Jan 14 09:53 .
-rw-r--r--   1 user group  514 Jan 14 06:42 bar
-rw-r--r--   1 user group 106M Jan 13 12:12 foo
drwx------+ 47 user group 1.5K Jan 12 18:08 ..
```
```
ls -laht --color=auto
```

- Write bash functions `marco` and `polo` that do the following. Whenever you execute `marco` the current working directory should be saved in some manner, then when you execute `polo`, no matter what directory you are in, `polo` should `cd` you back to the directory where you executed marco. For ease of debugging you can write the code in a file `marco.sh` and (re)load the definitions to your shell by executing `source marco.sh`.
```bash
#!/usr/bin/env zsh
macro(){
  export _marco=$(pwd)
}
polo(){
  cd "$_marco"
}
```

- Say you have a command that fails rarely. In order to debug it you need to capture its output but it can be time consuming to get a failure run. Write a bash script that runs the following script until it fails and captures its standard output and error streams to files and prints everything at the end. Bonus points if you can also report how many runs it took for the script to fail.
```bash
#!/usr/bin/env zsh

n=$(( RANDOM % 100 ))

if [[ n -eq 42 ]]; then
   echo "Something went wrong"
   >&2 echo "The error was using magic numbers"
   exit 1
fi

echo "Everything went according to plan"

#!/usr/bin/env zsh
count=0
until [[ "$?" -ne 0 ]]; # you need qoute it to expand the var
do
((count++)) # arithmetic expansion
./"$1" &> log.txt
done

echo "total execution times: $count"
cat log.txt

chmod +x debug.sh script.sh
./debug.sh script.sh
```
- Write a command that recursively finds all HTML files in the folder and makes a zip with them.
  - There’s the `xargs` command which will execute a command using STDIN as arguments. For example `ls | xargs rm` will delete the files in the current directory.
  - `xargs -d "\n"
```bash
find . -type f -name "*.html" | xargs -d "\n" tar -cf html.tar
```

- (Advanced) Write a command or script to recursively find the most recently modified file in a directory. More generally, can you list all files by recency?
```bash
find . -type f | ls -t | head -n1
```
# Extra
## export
In general, the export command marks an environment variable to be exported with any newly forked child processes and thus it allows a child process(another program) to inherit all marked variables. The environment variables of a process exist at runtime, and are not stored in some file. They are stored in the process's own memory (that's where they are found to pass on to children). But there is a virtual file in `/proc/pid/environ`.

## I/O Redirection
- Each open file gets assigned a file descriptor.
  - The file descriptors for *stdin*, *stdout*, and *stderr* are 0, 1, and 2
  - A *file descriptor* is simply a number that the operating system assigns to an open file to keep track of it.
- `1>filename` Redirect stdout to file filename.
- `1>>filename` Redirect and append stdout to file "filename.
- `2>filename` Redirect stderr to file filename.
- `2>>filename` Redirect and append stderr to file filename.
- `&>filename` Redirect both stdout and stderr to file filename.
- `M>&N` Redirect file descriptor M to file descriptor N
- So when you write `git status 2&>1`, it is therefore like `git status 2 1>1 2>1` , however name is only opened once.
  - the first 2 actually gets passed as an argument to git status.
  - stdout is redirected to the file named 1 (not the file descriptor 1)
  - stderr is redirected to the file named 1