local file = io.open("/proc/stat", "r")
local pfile = io.open("/tmp/cpu_usage_state_lua", "w")

local function print_table(_table)
	for key, v in pairs(_table) do
		print(key, v)
	end
	print("\n")
end

local function split_line(_line)
	CPU_FIELDS = {
		"user",
		"nice",
		"system",
		"idle",
		"iowait",
		"irq",
		"softirq",
		"guest",
		"guest_nice"
	}
	local result = {}
	local values = {}
	for value in string.gmatch(_line, "%S+") do
		table.insert(values, value)
	end
	for i, v in pairs(values) do
		if i <= #CPU_FIELDS then
			result[CPU_FIELDS[i]] = v
		end
	end

	return result
end

local function read_file(_file)
	local arr = {}
	if _file then
		for line in _file:lines() do
			if line:match("^cpu%d.*") then
				local words = split_line(line)
				table.insert(arr, words)
			end
		end
		_file:close()
	else
		print("Cant read file")
	end
	return arr
end

local arr = read_file(file)

if arr then
	for i, v in pairs(arr) do
		print(i, v)
	end
end
