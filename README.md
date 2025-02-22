![banner](banner.png)

---

## about

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

## usage

To create a divider / comment use the `:CreateDivider` user command. Example:\
`:CreateDivider <format> <length> <label ...>`
 - format - choose from predefined formats or from `@dev_buffer_format` to use your
 own formats. Look at `:h kommentar-nvim.setup-custom-formats` for more information about `@dev_buffer_format`
 - length - the length of the comment
 - label - no `'` or `"` needed everything after `length` is a part of label

 more information: `:h :CreateDivider`

## install

#### using lazy

```lua
-- for kommentar.nvim
{ 
    'duckifo/kommentar.nvim', 
    cmd = {'CreateDivider', 'KommentarVersion'}, 
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
    foramt = { foramt_name = '<format>' },
    -- if `commentString` should be on both sides
    comment_on_both_sides = true,
    -- the length to use if failed to convert passed length
    default_length = 50,
}
```

## format syntax

There are 2 types of characters `constant` and `generated` chars, constant chars are the chars that arent generated, this will make sense if you read the bellow! 

generated chars come from a macro / param, this duplicates characters or writes a string to the buffer,
a macro is initialized by `%` then followed by a parentheses with its coresponding closing parentheses, like this: `%()`
In the paren the first option is always a `operator`. The operator is followed
by a number in most cases, the number can corespond to how many times to repeat the char or how many percent out of length to repeat. Then followed by a
character / characters, these are the ones being repeated. Each of these are separated by `:`. It could look something like this: `%(?:50:~)`.

But lets pick a simple one `=` it repeats the character as many times as the number. For example\
`%(=:10:=)` would result in `==========` AKA 10 eq signs.

There is info about what each operator does, run `:h kommentar-nvim.format-syntax`
