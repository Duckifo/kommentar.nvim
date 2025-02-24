![banner](banner.png)

![preview](preview.gif)

---

# about

kommentar.nvim is a plugin for neovim that can split up
code by creating long ascii art comments with labels. These comments are generated 
from `formats` which defines the style of the comment.

```lua
-- <=:-~~~~~~~~ ) This is a divider! ( ~~~~~~~~-:=> --
-- <=:-~~~~~~~~~~~~~ ) This is a waaaay looonger divider! ( ~~~~~~~~~~~~-:=> --

-- ╭───────────────────────────────────────────────────────────────────────╮ --
-- │                      This is a way cooler divider                     │ --
-- ╰───────────────────────────────────────────────────────────────────────╯ --

-- ┌───────────────────────────────────────────────────────────────────────┐ --
-- │                      And this one is lame tbh B)                      │ --
-- └───────────────────────────────────────────────────────────────────────┘ --
```

 .. example format used above:\
 ` <=:-%(?:50:~) ) %(c:label) ( %(?:50:~|overflow)-:=> `

# usage

To create a divider / comment use the `:CreateDivider` user command. Example:\
`:CreateDivider <format> <length> <label ...>`
 - format - choose from predefined formats or from `@dev_buffer_format` to use your
 own formats. Look at `:h kommentar-nvim.setup-custom-formats` for more information about `@dev_buffer_format`
 - length - the length of the comment
 - label - no `'` or `"` needed everything after `length` is a part of label

 more information: `:h :CreateDivider`

# install

#### using lazy

```lua
-- for kommentar.nvim
{ 
    'duckifo/kommentar.nvim', 
    cmd = {'CreateDivider', 'KommentarVersion'}, 
    dependencies = { 'vhyrro/luarocks.nvim' },
    opts = {} 
}

-- requires luarocks.nvim
{
    "vhyrro/luarocks.nvim",
    priority = 1000,
    opts = {
        -- add required dependencie
        rocks = { 'utf8' }
    }
}
```

### configuration
```lua
{
    -- formats to add to the `CreateDivider` command at setup
    format = { format_name = '<format>' },
    -- if `commentString` should be on both sides
    comment_on_both_sides = true,
    -- the length to use if failed to convert passed length
    default_length = 50,
}
```

# Format
Formats defines the style of the divider, where the label should be, what characters to use etc...

### load

You can load formats into the formats module either from the setup config
or you can load it into the formats module anytime by doing:
```lua
require('kommentar-nvim.formats').formats[name] = format
require('kommentar-nvim.formats').reload_keys()
```

## generall

They follow simple operators to function, these operators repeat character or write whole strings to the buffer. 

To use a operator you prefix a parameter with `%` this can look something like this `%(arg1:arg2:arg3)` as you can see the arguments are separated by `:`. Argument 1 in this param is always the operator ( more down bellow ).
The following arguments are up to the operator to decide.

Before we go over what each operator does, you have to know what `constant` & `generated` characers are. 
```
constant characters
↓           ↓--↓
#%(/!:100:=)abcd
 ↑---------↑
The characters that will be generated 
here will be generated characters.
```

### operators
- `%(=:*x:*char)` - repeats char x many times
- `%(/=:*x:*char)` - repeats char x many percent out of length
- `%(!:*x:*char)` - repeats char x many percent out of length minus label length
- `%(/!:*x:*char)` - repeats char x many percent out of length minus constant chars.
- `%(?:*x:*char)` - repeats char x many percent out of length minus label length and constant chars.
- `%(c:*name:*char?)` - either writes a string to the buffer ( like the label ) or repeats the char !(char is not needed if it only writes to buffer).
    - `label` - writes the label to the buffer
    - `/label` - repeats the char as many times as the labels length

### modifiers
Modifiers change the buffer after its been generated. To use a modifier you separate a operator param with `|` might look like this `%(?:50:=|*mod-name)`

The `overflow` modifier is really important, lets go over the problem it solves first.

In some of the equations it handles float numbers, wich doent mix well with repeating characters, as you cant have half a character. So without the overflow modifier the divider wont take the right length when label length is wrong. This might not be a problem in single line comments but in multiline comments this result in awfullness.

The fix is using the overflow modifier. It will either make the generated chars of the operator longer or shorter. It might look like this:
`%(?:50:=|overflow)`
