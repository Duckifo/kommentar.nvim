# scd.nvim

> [!NOTE]
There is one flaw in the design in the moment, which results in comments not
being long enough when label length is even. This should only be noticeable in
"multi-line" comments.

## about

scd.nvim ( simpe comment divider .nvim ) is a plugin for neovim that can split up
code by creating long ascii art comments with labels. These comments are generated 
from `formats` which defines the style of the comment.

```lua
-- <=:-~~~~~~~ ) This is a divider! ( ~~~~~~~-:=> --
-- <=:-~ ) This is also a divider indeed! ( ~-:=> --

-- <=:-~~~~~~~ ) This is a waaaaaayy looooooooonger divider! ( ~~~~~~~-:=> --
-- <=:-~~~~~~~~~~~~ ) But this still, also is a divider! ( ~~~~~~~~~~~-:=> --
```

 .. example format used above:\
 ` <=:-%(?:50.05:~) ) %(c:label) ( %(?:50:~)-:=> `

## usage

To create a divider / comment use the `:ScdCreateDivider` user command. Example:\
`:ScdCreateDivider <format> <length> <label ...>`
 - format - choose from predefined formats or from `@dev_buffer_format` to use your
 own formats look at `:h scd-nvim.setup-custom-formats` for more information about `@dev_buffer_format`
 - length - the length of the comment
 - label - no `'` or `"` needed everything after `length` is a part of label

 more information: `:h :ScdCreateDivider`

## install

##### using lazy

```lua
{
    'duckifo/scd.nvim',
    config = function()
        require('scd-nvim').setup({})
    end
}
```
