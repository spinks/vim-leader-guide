# vim-leader-guide

vim-leader-guide is a vim keymap-display loosely inspired by emacs's [guide-key](https://github.com/kai2nenobu/guide-key).

This fork of `hecal3/vim-leader-guide` fixes issues and introduces many new features.

![vimleaderguide](https://i.imgur.com/WPLQZVn.png)

---
![vimleaderguide2](https://i.imgur.com/BqIunY6.png)

## Features
    - Show all global mappings
    - Show all buffer-local mappings (for plugins, etc.)
    - Show all mappings following a prefix (<leader>, <localleader>, etc.)
    - Dynamic update on every call
    - Define group names and arbitrary descriptions.
    - No default mappings, no autocomands. Does nothing on it's own.

## Installation

- [Plug](https://github.com/junegunn/vim-plug)
  - `Plug 'spinks/vim-leader-guide'`

For manual installation copy this repository somewhere and add its path to the vim runtimepath.

## Example Usage
For more detailed description of available commands and functions, and more configuration recommendations see the documentation.

Plugin configuration makes use of vim script's dictionary structures.

```vim
" Define prefix dictionary
let g:lmap = {}

" Simple command
nnoremap <leader>s :up<CR>
let g:lmap.s = 'save file'

" Define a group
let g:lmap.b = {'name' : 'buffers'}
" Create a dictionary with the special 'name' field

" A mapping within a group
nnoremap <leader>bl :ls<CR>
let g:lmap.b.l = 'list'
```

---

##Mappings 
Mappings can be defined in three ways.

#### Recommended 
- Set the mapping in vim as you would normally
    - `nnoremap <leader>s :up<CR>`
- Give the mapping a name in the leader guide dict (this is optional, it will otherwise display the raw command (ex. `:up`))
    - `let g:lmap.s = 'save file'`

This method gives more flexibility over the mappings, means that all mappings that you make can be executed without waiting for the leader menu pop up. 

This behaviour is also dictated and encouraged by the setting `g:leaderGuide_mode_local_only` which is set to `1`, enabled, by default. This means that only mappings which are available in vim (map, nmap, vmap) are displayed in the leader guide. This also helps in that mappings which are buffer local (filetype dependent) are only shown when in that filetype.

If you have the setting `g:leaderGuide_mode_local_only` disabled and have an entry in the dict defined by this method and not the list method described below you will encounter errors (it will execute the second character in the string, which is not desired).

#### Two Older Styles
##### One
- You can optionally set the mapping in vim
    - However, if you want the command to be available in the dict without setting the mapping in vim you need to set `g:leaderGuide_mode_local_only` to `0`, to show unmapped dict entries
- Give the mapping a name in the leader guide dict with the array method ([command, description])
    - `let g:lmap.s = ['up', 'save file']`

As mentioned this is less expressive, if you only have the mapping in the dict and not vim it will not be executable without waiting for the leader guide and you have to be able to wrap your mapping in quotes, which can sometimes be difficult.

Native vim mappings will always take precedence over dictionary-only mappings defined in this method.

##### Two
Depending on your use case extensive dictionary configuration mightn't be necessary.

Instead of
```vim
    nmap <silent> <leader>fd :e $MYVIMRC<CR>
    let g:lmap.f.d = ['e $MYVIMRC', 'Open vimrc']
```

One could simply use:
```vim
    nnoremap <Plug>(open-vimrc) :e $MYVIMRC<CR>
    nmap <leader>fd <Plug>(open-vimrc)
```

This variant is a lot less intrusive and just as descriptive as the dictionary variant above.
This way it is possible use dictionaries for group names only, and let native vim-mappings handle the rest.

It is also possible to hide the `<Plug>`-prefix and run other arbitrary functions like a custom search/replace or a simple value lookup on the display-name.

Consult the docs under **g:leaderGuide_displayfunc**

## Registering the Dictionary

To make the guide pop up Register the description dictionary for the prefix first
(Assuming Space is your leader):

```vim
call leaderGuide#register_prefix_descriptions("<Space>", "g:lmap")
nnoremap <silent> <leader> :<c-u>LeaderGuide '<Space>'<CR>
vnoremap <silent> <leader> :<c-u>LeaderGuideVisual '<Space>'<CR>
```

The guide will be up to date at all times.

It is possible to call the guide for keys other than `leader`:

```vim
nnoremap <localleader> :<c-u>LeaderGuide  ','<CR>
vnoremap <localleader> :<c-u>LeaderGuideVisual  ','<CR>
" This variant won't habe any group names.

" Group names can be defined by filetype. Add the following lines:
let g:llmap = {}
autocmd FileType tex let g:llmap.l = { 'name' : 'vimtex' }
call leaderGuide#register_prefix_descriptions(",", "g:llmap")
" to name the <localleader>-n group vimtex in tex files.
```

---

The dictionary configuration is necessary however, to provide group names or a description text.

After pressing `leader` the guide buffer will pop up when there are no further keystrokes within `timeoutlen`.

Pressing other keys within `timeoutlen` will either complete the mapping or open a subgroup.
In the example above `leader-b` will open up the buffer menu.

Please note that no matter which mappings and menus you configure, your original leader mappings will remain unaffected.
The key guide is an additional layer. It will only activate, when you do not complete your input during the timeoutlen duration.

## Display mappings without prefix

Additionally it is possible to display all buffer local mappings with `<Plug>leaderguide-buffer`.

This feature is useful to explore mappings defined by plugins in their respective buffers. (fugitive, tagbar, vimfiler, Nerdtree, etc.)
To make the usage of `<Plug>leaderguide-buffer'` in those plugin buffers more convenient one can make use of autocommands.

Examples:

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

" Remove the old prefixes
"call leaderGuide#register_prefix_descriptions(",", "g:llmap")
"call leaderGuide#register_prefix_descriptions("<Space>", "g:lmap")

This configuration will provide access to the `leader` and `localleader` spaces when calling with `<Plug>leaderguide-global`

Note: If the user does no configuration on their own the following default is set:

```vim
let g:leaderGuide_map = {}
call leaderGuide#register_prefix_descriptions('', 'g:leaderGuide_map')
```

It's possible to simply reuse this dictionary and enter own configuration.


## Configuration settings
### Hiding Mappings

It is now possible to hide mappings from the leader guide menu, while they are still executable from within the leader menu.

```vim
let g:lmap.w = `leader_ignore`
```

`leader_ignore` is the reserved keyword to hide from the menu.

This is useful for instance if you have a set of mappings to navigate between window numbers but do not want them all to clutter your leader guide.

### Mapping key names

It is possible to remap a key name to a different display name through the dictionary variable `g:leaderGuide_key_name_map`.
    - i.e. if one wanted to change the display name for the key `'b'` for whatever reason you would set `g:leaderGuide_key_name_map = {'b': 'custom'}`

The default dict included remaps the following keys to their respective display names:
```vim
{
    '<C-I>': '<Tab>',
    '<C-H>': '<BS',
    ' ': 'SPC'
}
```

### Match whole mapping
Setting the variable `g:leaderGuide_match_whole` to `1` allows for multi-key mappings where the root (all but last characters) of the multi-key mapping is a second function, however it also means that incorrect keys entered before the mapping will be read, meaning that there will be no function called. Alternatively leaving it as `0` (the default) will mean that it will only try and match the last key, allowing for incorrect key presses leading up to the correct key.
  - You should set this depending on your use. For instance if you need a function for one key, say `m` and then a second function for `mr` you should set this variable to `1`, if not leave it as `0`

### Visual
Popup position and orientation:

```vim
" Bottom (default)
" let g:leaderGuide_vertical = 0
" let g:leaderGuide_position = 'botright'

" Top
let g:leaderGuide_position = 'topleft'

" Left
let g:leaderGuide_vertical = 1
let g:leaderGuide_position = 'topleft'

" Right
let g:leaderGuide_vertical = 1
let g:leaderGuide_position = 'botright'
```

Minimum horizontal space between columns:

```vim
let g:leaderGuide_hspace = 5
```

Display menus with a "+" in-front of the description (à la emacs-which-key). Off by default. This also has custom syntax highlighting for menus when enabled.

```vim
let g:leaderGuide_display_plus_menus = 0
```

### Guide Updating
Don't update the guide automatically: (Not recommended)

```vim
let g:leaderGuide_run_map_on_popup = 0
```

The update is almost instantaneous and will only run when the guide actually pops up. Apart from that the automatic update has no performance impact.


## Fork Notes
A list of all changes in this fork is below, with todos:

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
#### Fork Todos
- Update docs
- ~~Add syntax highlighting for menu names when `g:leaderGuide_display_plus_menus` is enabled~~