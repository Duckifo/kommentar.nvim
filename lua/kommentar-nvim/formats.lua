-- Heyo there, this is just a file full with formats, looking for explaination do `:help kommentar.nvim-format`

--- A collections of hand crafter formats
--- Very nice B)
---@class Formats
---`@duckifo`
---```lua
--- 50:
--- -- <=:-~~~~~~~~~~~~ ) @duckifo ( ~~~~~~~~~~~~-:=> --
--- 100:
--- -- <=:-~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ) @duckifo ( ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~-:=> --
---```
---@field def_single string
---`@duckifo`
---```lua
--- 100:
--- -- (>- ------------------<=>------------------ @duckifo ------------------<=>------------------ -<) --
---```
---@field free_single string
---`@duckifo`
---```lua
--- 100:
--- -- <===:-~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~-:===> --
--- -- <:-                                        ( @duckifo )                                       -:> --
--- -- <===:-~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~-:===> --
---```
---@field def_triple string
---```lua
--- -- ╭────────────────────────────────────────────────────────────────────────────────────────────────╮ --
--- -- │                                            @duckifo                                            │ --
--- -- ╰────────────────────────────────────────────────────────────────────────────────────────────────╯ --
---```

---@type {formats: Formats, keys: string[], reload_keys: function}
local M = {}

---@type Formats
M.formats = {
	-- single lines
	simple_single = ' %(?:50:=) %(c:label) %(?:50:=|overflow) ',
	def_single = ' <=:-%(?:50:~) ) %(c:label) ( %(?:50:~|overflow)-:=> ',
	free_single = ' (>- %(?:25:-)<=>%(?:25.05:-) %(c:label) %(?:25.05:-)<=>%(?:25:-|overflow) -<) ',
	round_single = ' %(?:50: )%(c:label)%(?:50: |overflow) ',

	-- triple
	def_triple = ' <===:-%(/!:100:~)-:===> , <:-%(?:51.05: )( %(c:label) )%(?:50: |overflow)-:> , <===:-%(/!:100:~)-:===> ',
	square_triple = ' ┌%(/!:100:─)┐ , │%(?:50: )%(c:label)%(?:50: |overflow)│ , └%(/!:100:─)┘ ', 
	round_triple = ' ╭%(/!:100:─)╮ , │%(?:50: )%(c:label)%(?:50: |overflow)│ , ╰%(/!:100:─)╯ '
}

M.keys = {}
--- reload the keys from `M.formats`
M.reload_keys = function()
	-- reset keys
	M.keys = {}
	-- add new keys
	for key, _ in pairs(M.formats) do
		table.insert(M.keys, key)
	end
end

-- load the current keys
M.reload_keys()

---@return {formats: Formats, keys: string[]}
return M
