local M = {}


function M.whatTable(_table)
	if type(_table) ~= "table" then
		return "NotTable"
	end
	for i, v in pairs(_table) do
		if type(i) == "string" then
			return "DictTable"
		end
	end

	for i, v in ipairs(_table) do
		if type(i) == "number" then
			return "NumberTable"
		end
	end
	return "Underfined"
end

function M.readFile(path)
	return path
end

function M.createStrFromTable(_table, _name, _indent)
	local str = ""
	if _name then
		str = str .. string.rep('\t', _indent) .. _name .. " = {\n"
	end
	if M.whatTable(_table) == "DictTable" then
		for key, value in pairs(_table) do
			if type(value) == "table" then
				str = str .. M.createStrFromTable(value, key, _indent + 1)
			else
				str = str ..
				    string.rep('\t', _indent + 1) .. key .. " = \"" .. value .. "\",\n"
			end
		end
	else
		if M.whatTable(_table) == "NumberTable" then
			for key, value in pairs(_table) do
				if type(value) == "string" then
					str = str .. string.rep("\t", _indent + 1) .. "\"" .. value .. "\",\n"
				else
					str = str .. string.rep("\t", _indent + 1) .. value .. ",\n"
				end
			end
		end
	end
	if _name then
		if _indent == 0 then
			str = str .. string.rep("\t", _indent) .. "}\n"
		else
			str = str .. string.rep("\t", _indent) .. "},\n"
		end
	end
	return str
end

function M.saveTable(_path, _table, _name)
	local str_table = M.createStrFromTable(_table, _name, 0)
	str_table = str_table .. "return " .. _name
	local file = io.open(_path, "w")
	if file then
		file:write(str_table)
		file:close()
	end
end

function M.getSortedCpuData(t)
	local keys = {}

	for key in pairs(t) do
		table.insert(keys, key)
	end

	table.sort(keys, function(a, b)
		local num_a = tonumber(a:match("cpu(%d*)")) or -1
		local num_b = tonumber(b:match("cpu(%d*)")) or -1
		return num_a < num_b
	end)

	local sorted_data = {}
	for _, key in ipairs(keys) do
		table.insert(sorted_data, key)
	end

	return sorted_data
end

return M
