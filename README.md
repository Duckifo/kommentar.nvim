# kommentar.nvim

> [!NOTE]
There is one flaw in the design in the moment, which results in comments not
being long enough when label length is even. This should only be noticeable in
"multi-line" comments.

## about

kommentar.nvim is a plugin for neovim that can split up
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

To create a divider / comment use the `:CreateDivider` user command. Example:\
`:CreateDivider <format> <length> <label ...>`
 - format - choose from predefined formats or from `@dev_buffer_format` to use your
 own formats. Look at `:h kommentar-nvim.setup-custom-formats` for more information about `@dev_buffer_format`
 - length - the length of the comment
 - label - no `'` or `"` needed everything after `length` is a part of label

 more information: `:h :CreateDivider`

## install

##### using lazy

```lua
{ 'duckifo/kommentar.nvim', opts = {} }
```
