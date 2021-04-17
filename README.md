# vim-leader-guide

vim-leader-guide is a neovim keymap-display loosely inspired by emacs's [guide-key](https://github.com/kai2nenobu/guide-key).

This fork of `hecal3/vim-leader-guide` fixes issues and introduces many new features.

|![vimleaderguide](https://i.imgur.com/v1XWsdw.png) | The floating leader guide window, displayed in the default bottom position (left) and a vertical arrangement (below)  |
|--|--|
|![vimleaderguide2](https://i.imgur.com/7UPy0PK.png)| ![vimleaderguide3](https://i.imgur.com/ERF4jbu.png)|
## Features
- Show all global mappings
- Show all buffer-local mappings (for plugins, etc.)
- Show all mappings following a prefix (<leader>, <localleader>, etc.)
- Dynamic update on every call
- Define group names and arbitrary descriptions.
- No default mappings, no autocomands. Does nothing on it's own.
- Makes full use of neovims floating windows

## Installation

- [Plug](https://github.com/junegunn/vim-plug)
  - `Plug 'spinks/vim-leader-guide'`

For manual installation copy this repository somewhere and add its path to the neovim runtimepath.

## Minimal Configuration
With no nammed mappings the leader guide can still be displayed.
```vim
let mapleader = '\<Space>'
nnoremap <silent> <leader> :<c-u>LeaderGuide '<Space>'<CR>
vnoremap <silent> <leader> :<c-u>LeaderGuideVisual '<Space>'<CR>
```

To provide names a dictionary configuration is needed.
```vim
" Define prefix dictionary
let g:lmap = {}

" Simple command
nnoremap <leader>s :up<CR>
let g:lmap.s = 'save file'

" A command with a special (<...>) key
nnoremap <leader><Tab> :call feedkeys(":")<CR>
let g:lmap['<Tab>'] = 'cmd'

" To define a group create a dictionary with the special 'name' field
let g:lmap.b = {'name' : 'buffers'}

" A mapping within a group
nnoremap <leader>bl :ls<CR>
let g:lmap.b.l = 'list'

let mapleader = '\<Space>'
" Register the dictionary with leader guide
call leaderGuide#register_prefix_descriptions("<Space>", "g:lmap")
nnoremap <silent> <leader> :<c-u>LeaderGuide '<Space>'<CR>
vnoremap <silent> <leader> :<c-u>LeaderGuideVisual '<Space>'<CR>
```

## Mappings

Mappings can be defined in three ways.

#### Recommended
```vim
" Set the mapping in vim as you would normally
nnoremap <leader>s :up<CR>
" Give the mapping a name in the leader guide dict (optional: otherwise displaying the raw command (eg. :up))
let g:lmap.s = 'save file'
```

This method gives more flexibility over the mappings, means that all mappings that you make can be executed without waiting for the leader menu pop up.

This behaviour is encouraged by `g:leaderGuide_mode_local_only` which is enabled by default. This means that only mappings which are available in vim (map, nmap, vmap) are displayed in the leader guide. This also means that mappings which are buffer local (filetype dependent) are only shown when in that filetype.

If you have the setting `g:leaderGuide_mode_local_only` disabled and have an entry in the dict defined by this method and not the list method described below you will encounter errors (it will execute the second character in the string, which is not desired).

#### Two Older Styles
##### Dictionary-Only Mappings
You can optionally set the mapping in vim, but you will have to disable `g:leaderGuide_mode_local_only` to show unmapped entries.
```vim
let g:leaderGuide_mode_local_only = 0
let g:lmap.s = ['up', 'save file']
```

This method less expressive, you have to wait for the leader guide to execute dictionary-only mappings and you have to be able to wrap your function in quotes, which can sometimes be difficult. Native vim mappings will take precedence over dictionary-only mappings.

##### Plug Statements
You can use `<Plug>` statements to "name" mappings.

```vim
nnoremap <Plug>(open-vimrc) :e $MYVIMRC<CR>
nmap <leader>fd <Plug>(open-vimrc)
```

This way the dictionary need only contain the group names. It is also possible to hide the `<Plug>`-prefix and run other arbitrary functions like a custom search/replace or a simple value lookup on the display-name. Consult the docs under **g:leaderGuide_displayfunc**

## Registering the Dictionary

You then need to register the mapping dictionary with leader guide.
```vim
let mapleader = '\<Space>'
call leaderGuide#register_prefix_descriptions("<Space>", "g:lmap")
nnoremap <silent> <leader> :<c-u>LeaderGuide '<Space>'<CR>
vnoremap <silent> <leader> :<c-u>LeaderGuideVisual '<Space>'<CR>
```

It is possible to call the guide for keys other than `leader`.
```vim

let g:llmap = {}
" a filetype conditional group-name
autocmd FileType tex let g:llmap.l = { 'name' : 'vimtex' }

let maplocalleader = ','
call leaderGuide#register_prefix_descriptions(",", "g:llmap")
nnoremap <localleader> :<c-u>LeaderGuide  ','<CR>
vnoremap <localleader> :<c-u>LeaderGuideVisual  ','<CR>
```

After pressing `leader` the guide buffer will pop up when there are no further keystrokes within `timeoutlen`. Pressing other keys within `timeoutlen` will either complete the mapping or open a subgroup.

Note that no matter which mappings and menus you configure, original leader mappings will remain unaffected. The leader guide is an additional layer. It will only activate, when you do not complete your input during the timeoutlen duration.

## Display mappings without prefix

Additionally it is possible to display all buffer local mappings with `<Plug>leaderguide-buffer`.

This feature is useful to explore mappings defined by plugins in their respective buffers. (fugitive, tagbar, vimfiler, Nerdtree, etc.) To make the usage of `<Plug>leaderguide-buffer'` in those plugin buffers more convenient one can make use of autocommands.

```vim
autocmd FileType gitcommit  noremap <buffer> <leader> <Plug>leaderguide-buffer
" for fugitive

autocmd BufEnter __Tagbar__  noremap <buffer> <leader> <Plug>leaderguide-buffer
" for tagbar
```

To open a guide showing not only the buffer-local but all mappings use `<Plug>leaderguide-global`

To name items on this level, the dictionaries for `leader`, `localleader`, from the examples above, as well as other dictionaries one might have defined, can be combined into a single top-level dictionary:

```vim
let g:topdict = {}
let g:topdict[' '] = g:lmap
let g:topdict[' ']['name'] = '<leader>'
let g:topdict[','] = g:llmap
let g:topdict[',']['name'] = '<localleader>'

call leaderGuide#register_prefix_descriptions("", "g:topd")
```

This configuration will provide access to the `leader` and `localleader` spaces when calling with `<Plug>leaderguide-global`


## Configuration settings
### Hiding Mappings

It is possible to hide mappings from the leader guide menu, while they are still executable.

```vim
let g:lmap.w = 'leader_ignore'
```

`leader_ignore` is the reserved keyword to hide from the menu. This is useful for instance if you have a set of mappings to navigate between window numbers but do not want them all to clutter your leader guide.

### Mapping key names

It is possible to remap a key name to a different display name through setting the dictionary variable `g:leaderGuide_key_name_map`.
    - i.e. if one wanted to change the display name for the key `'b'` for whatever reason you would set `g:leaderGuide_key_name_map = {'b': 'custom'}`

If not defined leader guide remaps the following keys to the following respective display names: `<C-I>`: `<Tab>`, `<C-H>`: `<BS>`, `' '`: `SPC`.

### Match whole mapping
Setting the variable `g:leaderGuide_match_whole` to `1` allows for multi-key mappings where the root (all but last characters) of the multi-key mapping is a second function, however it also means that incorrect keys entered before the mapping will be read, meaning that there will be no function called. Alternatively leaving it as `0` (the default) will mean that it will only try and match the last key, allowing for incorrect key presses leading up to the correct key.
  - You should set this depending on your use. For instance if you need a function for one key, say `m` and then a second function for `mr` you should set this variable to `1`, if not leave it as `0`

### Visual
#### Floating Windows
vim-leader-guide now makes use of neovim's floating windows API by default (vim popup window compatibility to be added).

With this change the styling may be affected, this is due to the default highlight style for floating windows (`NormalFloat`) potentially being different to normal. vim-leader-guide uses this highlighting as default behaviour to avoid confusion. To change the styling simply link the `LeaderGuideFloating` highlight to any other, for example, to go back to the old style do:
```vim
hi def link LeaderGuideFloating Normal
```

#### Positional
Popup position and orientation:
```vim
" Horizontal modes (default)
let g:leaderGuide_vertical = 0
  " Bottom (default)
  let g:leaderGuide_position = 'botleft'

  " Top
  let g:leaderGuide_position = 'topleft'

" Vertical modes
let g:leaderGuide_vertical = 1
  " Left
    " With mappings at the bottom of the screen
    let g:leaderGuide_position = 'botleft'

    " With mappings at the top of the screen
    let g:leaderGuide_position = 'topleft'

  " Right
    " With mappings at the bottom of the screen
    let g:leaderGuide_position = 'botright'

    " With mappings at the top of the screen
    let g:leaderGuide_position = 'topright'
```

Minimum horizontal space between columns:
```vim
let g:leaderGuide_hspace = 5
```

#### Menus
Display menus with a "+" in-front of the name. Off by default. This also has custom syntax highlighting when enabled.
```vim
let g:leaderGuide_display_plus_menus = 0
```

## Development Notes
<details>
  <summary>Enclosed is a detailed list of all changes on this fork</summary>

- Can now set map descriptions without having to manually make a list and rewrite the keys
  - i.e. if you previously had a mapping `nnoremap <leader>m :call func()<CR>` you would have had to make the description using the method `let g:lmap.m = ['call func()', 'description']`. Now it can be done as simply as this, `let g:lmap.m = 'description'`
- Added ability to hide shortcuts from leader menu, while still being executable from within the leader menu,
	- Done by setting shortcut description to `"leader_ignore"`
	- i.e. `let g:lmap.w = ['call func()', 'leader_ignore']`
- Fix bug where: on entering incorrect keybindings the cursor would jump to the top of the file you were editing
- The leader menu now sets the statusline title to the name of the submenu, if in a submenu, otherwise maintaining original behaviour.
	- i.e. if in a 'buffer' submenu the statusline will display 'buffer' instead of 'Leader Guide'
- Fix bug where: on calling LeaderGuideD before calling LeaderGuide an error would throw due to undefined s:reg variable
- Add option to display menu keys with a "+" in-front of the description if they expand into a submenu (à la emacs-which-key)
	- option is `g:leaderGuide_display_plus_menus = 0`, off by default
	- also added syntax highlighting such that submenus are highlighted differently to functions in the guide
- The leader menu will now wait for a either a correct input to perform the action, or escape/enter to exit the menu
- Add variable `g:leaderGuide_key_name_map` which is a dict which can be defined by the user to add alternate display names for the keys they map, by default this is not initialised
	- i.e. if one wanted to change the display name for the key `'b'` for whatever reason you would set `g:leaderGuide_key_name_map = {'b': 'custom'}`
	- `<space>` mappings which would previously display `[ ]` now display `[SPC]`
	- with this the layout calculation now takes these mappings into consideration
- Add variable `g:leaderGuide_match_whole`, setting this to `1` allows for multi-key mappings where the root (all but last characters) of the multi-key mapping is a second function, however it also means that incorrect keys entered before the mapping will be read, meaning that there will be no function called. Alternatively leaving it as `0` (the default) will mean that it will only try and match the last key, allowing for incorrect key presses leading up to the correct key.
  - You should set this depending on your use. For instance if you need a function for one key, say `m` and then a second function for `mr` you should set this variable to `1`, if not leave it as `0`
- Fix issues with mappings to Tab key when these are defined in your mapping dict.
- Add variable `g:leaderGuide_mode_local_only`, set to `1` (enabled) by default, this option will filter the guide to only show keys that are mapped in vim (i.e. not only defined in the leader guide dict, map nmap or vmap keys), this allows for custom descriptions for buffer local (filetype dependent) mappings to only show when in that filetype as the base map would be unavailable.
  - Also fixes issue where if a mapping is described by only a string description instead of traditional list entry and that mapping is not natively mapped in the current mode (visual/normal) or buffer (filetype) it would take the second character of the string, as these are now filtered this is not an issue
  - If you want mappings to appear in both normal and visual modes make sure to just map not nmap or vmap
- Make use of neovim's floating windows
  - Allow aligning mappings to top or bottom in vertical window modes
</details>
