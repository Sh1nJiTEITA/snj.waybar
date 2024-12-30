-- local cio = require("./cio")

local M = {}

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

function M.readNewCpuData()
	local file = io.open("/proc/stat", "r")
	local arr = {}
	if file then
		for line in file:lines() do
			if line:match("^cpu%d.*") then
				local words = split_line(line)
				-- table.insert(arr, words)
				arr[words.user] = words
			end
		end
		file:close()
	else
		print("Cant read file")
	end
	return arr
end

function M.calcCpuUsage(prev_data, current_data)
	local cpu_usage = {}
	local total_delta_active = 0
	local total_delta_total = 0


	local function calculate_times(data)
		local total_time = 0
		local idle_time = data.idle + data.iowait

		for key, value in pairs(data) do
			if key ~= "user" then
				total_time = total_time + tonumber(value)
			end
		end

		local active_time = total_time - idle_time

		return total_time, active_time
	end

	for cpu, curr_values in pairs(current_data) do
		local prev_values = prev_data[cpu]

		if prev_values then
			local prev_total, prev_active = calculate_times(prev_values)
			local curr_total, curr_active = calculate_times(curr_values)

			local delta_total = curr_total - prev_total
			local delta_active = curr_active - prev_active

			total_delta_total = total_delta_total + delta_total
			total_delta_active = total_delta_active + delta_active
			--
			if delta_total > 0 then
				cpu_usage[cpu] = (delta_active / delta_total) * 100
			else
				cpu_usage[cpu] = 0
			end
		end
	end

	cpu_usage["cpu"] = (total_delta_active / total_delta_total) * 100
	return cpu_usage
end

return M
