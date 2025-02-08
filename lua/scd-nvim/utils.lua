local utils = {}

---@param str string
---@param sep string char
---@return string[]
function utils.split(str, sep)
	local result = {}
	for match in str:gmatch("([^" .. sep .. "]+)") do
		table.insert(result, match)
	end
	return result
end

---@param tbl string[]
---@param value string 
---@return boolean
function utils.includes(tbl, value)
	for _, v in ipairs(tbl) do
		if v == value then
			return true
		end
	end
	return false
end

return utils
