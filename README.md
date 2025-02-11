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

## install

##### using lazy

```lua
{
    'duckifo/scd.nvim',
    config = function()
        require('scd-nvim').setup({})
    end,
}
```
<details>
<summary> optionally setup simple format, label & length picker </summary>

```lua
{
    'duckifo/scd.nvim',
    config = function()
        -- setup
        require('scd-nvim').setup({})
        -- bind command
        vim.keymap.set('n', '<leader>gcd', function()
            -- get all formats
            local formats = require('scd-nvim.formats')
            local items = {}
            for key, _ in pairs(formats) do
                table.insert(items, key)
            end
            -- get what format to use
            local format_input
            vim.ui.select(items, { prompt = 'Format to use: ' }, function(choice)
                if choice then
                    format_input = choice
                    print("You selected: " .. choice)
                end
            end)
            if not format_input then return end

            -- get the label to use
            local label_input = ''
            vim.ui.input({ prompt = 'Enter label: ' }, function(input)
                label_input = input
            end)

            -- get len
            local len_input
            while true do
                vim.ui.input({ prompt = 'Enter length: ' }, function(input)
                    len_input = tonumber(input)
                end)
                if len_input then break 
                else print('please input a valid number') end
            end

            -- create the divider
            vim.cmd('ScdCreateDivider '.. len_input ..';' .. label_input .. ';' .. formats[format_input])
        end)
    end
}
```
</details>
