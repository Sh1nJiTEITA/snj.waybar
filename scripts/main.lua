local cio = require("./utils/cio")
local cpu = require("./utils/cpu")

local my_table = {
	name = "John",
	age = 30,
	address = {
		street = "123 Elm Street",
		city = "Somewhere"
	},
	hobbies = { "reading", "cycling", "hiking" },
	numbers = { 1, 2, 3, 4 },
	numbers_and = { 1, "dasdasd", 3, 4 },
}

local my_table2 = {
	"dasdsa",
	"dadasd",
	"3213123"
}


local gpu_table = cpu.readNewCpuData()


local last_cpu = require("./last_cpu_data")
local deltas = cpu.calcCpuUsage(last_cpu, gpu_table)

for i, v in pairs(deltas) do
	print(i, v)
end





cio.saveTable("./last_cpu_data.lua", gpu_table, "CPU_DATA")
