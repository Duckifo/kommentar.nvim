-- Heyo there, this is just a file full with formats, looking for explaination do `:help scd.nvim-format`
-- WARNING, multiline comments have some problems, the prefixes are kinda handled like shiiiit. It is just tricky

	--- A collections of hand crafter formats
	--- Very nice B)
---@class Formats
	---`@duckifo`
	---```lua
		--- 50:
		--- -- <=~~~~~~~~= label here =~~~~~~~~=> --
		--- 50+:
		--- -- <=~~~~~= looooonger label =~~~~~=> --
		--- 100:
		--- -- <=~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~= label here =~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~=> --
		--- 100+:
		--- -- <=~~~~~~~~~~~~~~~~~~~~= this is a waaaaaaay looooonger label =~~~~~~~~~~~~~~~~~~~~=> --
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
		--- -- <==:-~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~-:==> --
		--- -- <=:~                     label here                      ~:=> --
		--- -- <==:-~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~-:==> --
	---```
---@field def_triple string


---@return Formats
---@type Formats
return {
	def_single = ' <=~%?50= %t =~%?50=> ',
	free_single = ' <=:~ %?50%t %?50~:=> ',
	def_triple = ' <==:-~%l-:==> , <=:~  %!50%t  %!50~:=> , <==:-~%l-:==> '
}

