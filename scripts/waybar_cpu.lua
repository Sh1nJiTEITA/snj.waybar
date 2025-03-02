-- package.path = package.path .. ";/home/snj/Code/lua_utils/utils/?.lua"
package.path = package.path .. ";/home/snj/.config/waybar/scripts/?.lua"
-- package.path = package.path .. ";/home/snj/Code/lua_utils/?.lua"
-- package.path = package.path .. ";/home/snj/Code/lua_utils/?.lua"

local cio = require("cio")
local cpu = require("cpu")

local gpu_table = cpu.readNewCpuData()
local last_cpu = require("last_cpu_data")
local deltas = cpu.calcCpuUsage(last_cpu, gpu_table)

local out_str = ""

local function format_number(number)
	if number >= 10 then
		return string.format("%.1f", number)
	else
		return string.format("%.2f", number)
	end
end

out_str = out_str .. "{"
out_str = out_str .. '"text" : "'

out_str = out_str .. '<span foreground=\\"#fe8019\\"> </span>' .. format_number(deltas["cpu"]) .. "%"

out_str = out_str .. '",'

out_str = out_str .. '"tooltip" : "'

local sorted = cio.getSortedCpuData(deltas)

for _, key in ipairs(sorted) do
	if key ~= "cpu" then
		local formatted_value = format_number(deltas[key])
		if _ ~= #sorted then
			out_str = out_str .. " " .. key .. "\t= <b>" .. formatted_value .. "%</b>\\n"
		else
			out_str = out_str .. " " .. key .. "\t= <b>" .. formatted_value .. "%</b>"
		end
	end
end

out_str = out_str .. '"'
out_str = out_str .. "}"

print(out_str)

cio.saveTable("./last_cpu_data.lua", gpu_table, "CPU_DATA")
