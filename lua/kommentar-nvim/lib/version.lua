local version = {}

--- get the locally installed version by git tag
---@return string | nil
version.get_local_version = function()
	-- requires git to be installed and in some cases connected to internet
	local tags = vim.fn.system('git describe --tags'):gsub('\n', '')

	-- if tags not found fetch from repo
	if not tags then
		local success = vim.fn.system('git fetch --tags')
		if not success then
			vim.api.nvim_err_writeln('Failed to fetch --tags from github repo, ensure connection to Internet')
			return nil
		end

		-- get tags again
		tags = vim.fn.system('git describe --tags'):gsub('\n', '')
	end
	return tags
end

return version
