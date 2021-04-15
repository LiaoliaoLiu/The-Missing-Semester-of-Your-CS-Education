# Lecture
## Philosophy of Vim
- Vim is a modal editor
- Vim is programmable (Vimscript, Python and so on)
- Vim’s interface itself is a programming language
- Vim avoids the use of the mouse, because it’s too slow; Vim even avoids using the arrow keys because it requires too much movement.

## Modal editing
For this reason, Vim has multiple operating modes.
- Normal: for moving around a file and making edits
- **I**nsert: for inserting text
- **R**eplace: for replacing text
- **V**isual (plain, line `shift+v`, or block `control+v`): for selecting blocks of text
- Command-line`:` for running a command

I remapping vim_escpe in VScode to Caps.

## Basics
### Buffers, tabs, and windows
- Open files are *buffers* in vim
- A Vim session has has a number of *tabs*, which has arbitrary numbers of *windows* (include 0)
- Each window shows a single buffer.
- Buffers and windows are not corespondent. `:q` close a window not a buffer. When you close all windows, you quit vim.

### Command-line
- `:q` quit (close window)
- `:w` save (“write”)
- `:wq` save and quit
- `:e {name of file}` open file for editing
- `:ls` show open buffers
- `:help` {topic} open help
  - `:help :w` opens help for the :w command
  - `:help w` opens help for the w movement

## Vim's interface is a programming language
### Movement
Movements in Vim are also called “nouns”, because they refer to chunks of text.
- Basic movement: `hjkl` (left, down, up, right)
- Words: `w` (next word), `b` (beginning of word), `e` (end of word)
- Lines: `0` (beginning of line), `^` (first non-blank character), `$` (end of line)
- Screen: `H` (top of screen), `M` (middle of screen), `L` (bottom of screen)
- Scroll: `Ctrl-u` (up), `Ctrl-d` (down)
- File: `gg` (beginning of file), `G` (end of file)
- Line numbers: `:{number}<CR>` or `{number}G` (line {number})
- Misc: `%` (corresponding item)
- Find: `f{character}`, `t{character}`, `F{character}`, `T{character}`
  - find/to forward/backward {character} on the current line
  - `,` / `;` for navigating matches (Repeat latest f, t, F or T count times)
- Search: /`{regex}`, `n` / `N` for navigating matches

### Selection
- Visual: v
- Visual Line: V
- Visual Block: Ctrl-v (rectangle selection anchoring at center point)
### Edits
- `d{motion}` delete {motion}
  - e.g. `dw` is delete word, 
  - `d$` is delete to end of line, 
  - `d0` is delete to beginning of line
- `c{motion}` change {motion}
  - e.g. `cw` is change word
  - like `d{motion}` followed by i
- `x` delete character (equal do `dl`)
- `s` substitute character (equal to `xi`)
- `u` to undo, `<C-r>` to redo
- `~` flips the case of a character

### Counts
### Modifiers
Some modifiers are i, which means “inner” or “inside”, and a, which means “around”.

- `ci(` change the contents inside the current pair of parentheses
- `ci[` change the contents inside the current pair of square brackets
- `da'` delete a single-quoted string, including the surrounding single quotes

## Advanced Vim
### Search and replace
`:s` (substitute) command ([documentation](https://vim.fandom.com/wiki/Search_and_replace)).

- `:s/foo/bar/g` replace foo with bar in current line
  - `%s/foo/bar/g` replace foo with bar globally in file
  - The `g` flag means global (without `/g` it will only delete the first occurrence), when `:set gdefault`, `g` reverses its meaning.
  - `:5,12s/foo/bar/g`
  - `:.,$s/foo/bar/g`
  - `:.,+2s/foo/bar/g`
  - `:g/^baz/s/foo/bar/g` Change each 'foo' to 'bar' in each line starting with 'baz'.
  - `:%s/foo/bar/gci` `c` ask for confirmation; `i` case insensitive
- `%s/\[.*\](\(.*\))/\1/g` replace named Markdown links with plain URLs
  - `+`, `?`, `|`, `&`, `{`, `(`, and `)` must be escaped to use their special function.
  - `[]` specifies a collection. a letter a, b, c, or the number 1 can be matched with `[1a-c]`.
  - `\{#\}` is used for repetition. `/foo.\{2\}` will match foo and the two following characters. The \ is not required on the closing } so `/foo.\{2}` will do the same thing.
  - `\(foo\)` makes a backreference to foo. `\1` inserts the text of the first backreference.

### Multiple windows
- `:sp` / `:vsp` to split windows
- Can have multiple views of the same buffer.

### Macros
- Macros can be recursive.