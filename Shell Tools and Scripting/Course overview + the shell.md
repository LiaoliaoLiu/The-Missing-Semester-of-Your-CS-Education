# Lecture
## Basics
Shell determines the location you put programs by environment variables. They are set whenever you start the shell.

- `$PATH` shows all the paths the shell will seach for programs
```
$ echo $PATH
/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/mnt/s/Tools/Xshell/:/mnt/c/WINDOWS/system32:/mnt/c/WINDOWS:/mnt/c/WINDOWS/System32/Wbem:/mnt/c/WINDOWS/System32/WindowsPowerShell/v1.0/:/mnt/c/WINDOWS/System32/OpenSSH/:/mnt/s/Microsoft VS Code/bin:/mnt/c/Program Files/PuTTY/:/mnt/s/Git/cmd:/mnt/s/Git/mingw64/bin:/mnt/s/Git/usr/bin:/mnt/c/Program Files/dotnet/:/mnt/s/Python/Python38-32/Scripts/:/mnt/s/Python/Python38-32/:/mnt/c/Users/65481/AppData/Local/Programs/Python/Launcher/:/mnt/c/Users/65481/AppData/Local/Microsoft/WindowsApps:/mnt/c/Program Files/Bandizip/:/mnt/c/Users/65481/AppData/Local/GitHubDesktop/bin:/mnt/c/Users/65481/AppData/Local/Microsoft/WindowsApps
```
- `which` can let you the path of the program
```
$ which cat
/usr/bin/cat
```
- present working directory
```
$ pwd
/home/nev
```
- `cd -` will go to the previous directory
```
$ cd -
/mnt/c/Users/
/mnt/c/Users/ $
```
- how to read usage
  - usage: `ls [OPTION]... [FILE]...`
  - ... means one or more arguments
  - when it don't take value, we call it flags; otherwise, we call it option

- If you have a write permission on a file but don't have the permission on the directory, you can empty the file but you can't delete the file.
- execute permission on a directory is called search, which means if you are allowed to enter the directory.

## Handy Programs and Shortcuts
- In linux rm is not default recursive, use rm -r to rm a dir.
- Ctrl + L to clean the terminal screen
- < indicates rewire the input of this program to be the contents of this file
```
$ echo hello > hello.txt
$ cat hello.text
hello
```
- \> inidcates rewire the output of the preceding program into this file
```
$ cat < hello.txt > hello2.txt 
$ cat hello2.txt
hello
```
- \>> indicates append
- | pine can use the output of the right program as the input of the left
```
$ ls -l / | tail -n1
drwxr-xr-x  13 root root   4096 Aug  4  2020 var
```
- xdg-open \<file> open a file with a correct program
## Kernel Parameters sys
```
$ cd /sys
block  bus  class  dev  devices  firmware  fs  kernel  module
```
There is a case where you want to change a file use pipe, but you need root permission to non-first programs.
```
$ sudo echo 500 > brightness
Permission denied
```
You can
1. change to root user by sudo su
2. use tee command (run tee as root and let tee do the thing)
```
$ echo 500 | sudo tee brightness
```

# Notes
## Navigating in the shell
- A path on the shell is a delimited list of directories; separated by / on Linux and macOS and \ on Windows
- On Linux and macOS, the path / is the “root” of the file system, under which all directories and files lie, whereas on Windows there is one root for each disk partition (e.g., C:\).
- A path that starts with / is called an absolute path. Any other path is a relative path. Relative paths are relative to the current working directory
  - pwd - present working directory
  - .   - current directory
  - ..  - parent directory


```
missing:~$ ls -l /home
drwxr-xr-x 1 missing  users  4096 Jun 15  2019 missing
```
- Command: ls -l
  - The d at the beginning of the line tells us that missing is a directory
  - These indicate what permissions the **owner** of the file (missing), the **owning group** (users), and **everyone else**.
- Command: man \<program name>
  - shows you the program's manual page

## A versatile and powerful tool
```
$ sudo echo 3 > brightness
An error occurred while redirecting file 'brightness'
open: Permission denied
```
Operations like `|`, `>`, and `<` are done *by the shell*, not by the individual program. echo and friends do not “know” about `|`.

# Exercises
- Try to execute the file, i.e. type the path to the script (./semester) into your shell and press enter. Understand why it doesn’t work by consulting the output of ls (hint: look at the permission bits of the file).
  - Touch creates a file with no execute perm

- Look up the chmod program (e.g. use man chmod).
  - ugoa: current user, current user's group, other groups, anyone
  - rwxXst: 
    - X: execute only if the file is a directory or already has execute permission for some user
    - s: set user or group ID on execution
    - t: restricted deletion flag or sticky bit (only onwers can delete it)
    - `chmod <file> _777` (4+2+1=7 111)
  - If none  of these  are given, the effect is as if (a)

- Use `|` and `>` to write the “last modified” date output by semester into a file called `last-modified.txt` in your home directory.
  - `./semester | head -n4 | tail -n1 > ~/last-modified.txt`

# Extra
## The setuid bit
The ownership of files and directories is based on the default `uid` (user-id) and `gid` (group-id) of the user who created them. *The same thing happens when a process is launched*: it runs with the effective `user-id` and `group-id` of the user who started it, and with the corresponding privileges. This behavior can be modified by using special permissions.

When the setuid bit is used, the behavior described above it's modified so that when an executable is launched, **it does not run with the privileges of the user who launched it, but with that of the file owner instead.** So, for example, if an executable has the setuid bit set on it, and it's owned by root, when launched by a normal user, it will run with root privileges. It should be clear why this represents a potential security risk, if not used correctly.

```
ls -l /bin/passwd
-rwsr-xr-x. 1 root root 27768 Feb 11  2017 /bin/passwd
```
The `setuid` bit is represented by an `s` in place of the x of the executable bit. 