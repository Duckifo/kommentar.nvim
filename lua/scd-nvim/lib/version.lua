local version = {}

--- get the locally installed version by git tag 
---@return string
version.get_local_version = function ()
	-- requires git to be installed
	return vim.fn.system('git describe --tags'):gsub('\n', '')
end
return version
