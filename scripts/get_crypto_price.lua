local http = require("socket.http")
local json = require("dkjson")
local ltn12 = require("ltn12")

local function print_table(tbl, indent)
   indent = indent or 0
   local formatting = string.rep("  ", indent)

   if type(tbl) ~= "table" then
      print(tostring(tbl))
      return
   end

   for key, value in pairs(tbl) do
      if type(value) == "table" then
         print(formatting .. tostring(key) .. ":")
         print_table(value, indent + 1)
      else
         print(formatting .. tostring(key) .. ": " .. tostring(value))
      end
   end
end

local function round(num, dp)
   --[[
    round a number to so-many decimal of places, which can be negative, 
    e.g. -1 places rounds to 10's,  
    
    examples
        173.2562 rounded to 0 dps is 173.0
        173.2562 rounded to 2 dps is 173.26
        173.2562 rounded to -1 dps is 170.0
    ]]
   --
   local mult = 10 ^ (dp or 0)
   return math.floor(num * mult + 0.5) / mult
end

local function get_price(_symbol)
   local url = "https://api-testnet.bybit.com/v5/market/tickers?category=spot&symbol=" .. _symbol
   local response_body = {}

   local _, code = http.request({
      url = url,
      method = "GET",
      sink = ltn12.sink.table(response_body),
   })

   if code ~= 200 then
      print("HTTP request failed with code:", code)
      return
   end

   local response_str = table.concat(response_body)

   local data, pos, err = json.decode(response_str, 1, nil)

   if err then
      print("Error parsing JSON:", err)
   else
      local price = data.result.list[1].usdIndexPrice
      return round(price, 1)
      -- return data.result.list[1].usdIndexPrice
   end
end

local symbol_btc = "BTCUSDT"
local price_btc = get_price(symbol_btc)

local symbol_eth = "ETHUSDT"
local price_eth = get_price(symbol_eth)

print(price_btc, price_eth)
