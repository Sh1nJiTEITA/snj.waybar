#!/bin/bash

URL=$1
CATEGORY=$2
SYMBOL=$3
PREV_PRICE_FILE="/tmp/prev_${SYMBOL}_price.txt"

get_current_price() {
    local _URL=$1
    local _CATEGORY=$2
    local _SYMBOL=$3
    local _PRECISION=$4
    response=$(curl -s -G "$_URL" \
      --data-urlencode "category=$_CATEGORY" \
      --data-urlencode "symbol=$_SYMBOL")
    current_price=$(echo "$response" | jq -r '.result.list[0].usdIndexPrice')
    current_price=$(printf "%.${_PRECISION}f" "$current_price")
    echo $current_price
}

print_current_price() { 
  local _current_price=$1
  local _prev_price=$2
  local _symbol=$3

  local class=""
  local arrow=""
  local percentage=""
  local tooltip=""
  local color=""

  if [ -f "${_prev_price}" ]; then
      prev_price=$(cat "$_prev_price")
      if (( $(echo "$_current_price > $prev_price" | bc -l) )); then
          class="up"
          arrow="\uf062"
          color="green"
          percentage=$(echo "scale=2; (($current_price - $prev_price) / $prev_price) * 100" | bc)
      elif (( $(echo "$_current_price < $prev_price" | bc -l) )); then
          class="down"
          arrow="\uf063"
          color="red"
          percentage=$(echo "scale=2; (($prev_price - $current_price) / $prev_price) * 100" | bc)
      else
          class="unchanged"
          arrow="\uf07d"
          color="yellow"
          percentage=0
      fi
  fi

  local coin_color="#d79921"
  # echo "{\"text\": \"<span foreground=\\\"$coin_color\\\">${_symbol}</span> <span foreground=\\\"$color\\\">$arrow</span> $_current_price\$\", \"alt\": \"$_current_price\", \"tooltip\": \"${_symbol} Price: $_current_price\\nChange: $percentage%\", \"class\": \"$class\", \"percentage\": $percentage }"
  echo "{\"text\": \"${_symbol} $arrow $_current_price\$\", \"alt\": \"$_current_price\", \"tooltip\": \"${_symbol} Price: $_current_price\\nChange: $percentage%\", \"class\": \"$class\", \"percentage\": $percentage }"

  echo "$_current_price" > "$_prev_price"
}

current_price=$(get_current_price $URL $CATEGORY $SYMBOL 1)
print_current_price "$current_price" "$PREV_PRICE_FILE" $SYMBOL
