-- Heyo there, this is just a file full with formats, looking for explaination do `:help scd.nvim-format`

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
		--- 
	---```
---@field free_single string
	---`@duckifo`
	---```lua
		--- 100:
	---```
---@field def_triple string


---@return Formats
---@type Formats
return {
	-- single lines
	def_single = ' <=:-%(?:50.05:~) ) %(c:label) ( %(?:50:~)-:=> ',
	free_single = '',

	-- triple
	def_triple = ''
}

-- (>- %(?:50:-) %(c:label) %(?:50:-) -<) 
-- (>- --------------- hello! --------------- -<) --
