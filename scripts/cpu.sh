#!/bin/bash

STATE_FILE="/tmp/cpu_waybar_state"
PREV_TOTAL=0
PREV_IDLE=0

if [ -f "$STATE_FILE" ]; then
    read -r PREV_TOTAL PREV_IDLE < "$STATE_FILE"
    # echo "${PREV_TOTAL}/${PREV_IDLE}"
fi

CPU=($(head -n1 /proc/stat))

IDLE=${CPU[4]}
TOTAL=0
for VALUE in "${CPU[@]:1}"; do
    TOTAL=$((TOTAL + VALUE))
done

DIFF_IDLE=$((IDLE-PREV_IDLE))
DIFF_TOTAL=$((TOTAL-PREV_TOTAL))

if [ "$DIFF_TOTAL" -ne 0 ]; then
    # DIFF_USAGE=$((100 * (DIFF_TOTAL - DIFF_IDLE) / DIFF_TOTAL))        
    DIFF_USAGE=$(awk "BEGIN {printf \"%.2f\", 100 * ($DIFF_TOTAL - $DIFF_IDLE) / $DIFF_TOTAL}")
else 
    DIFF_USAGE=0.00
fi

usage_int=$(printf "%.0f" "$DIFF_USAGE")
format_icons=("▁" "▂" "▃" "▄" "▅" "▆" "▇" "█")

if [ "$usage_int" -ge 88 ]; then
    icon="${format_icons[7]}"
elif [ "$usage_int" -ge 75 ]; then
    icon="${format_icons[6]}"
elif [ "$usage_int" -ge 63 ]; then
    icon="${format_icons[5]}"
elif [ "$usage_int" -ge 50 ]; then
    icon="${format_icons[4]}"
elif [ "$usage_int" -ge 38 ]; then
    icon="${format_icons[3]}"
elif [ "$usage_int" -ge 25 ]; then
    icon="${format_icons[2]}"
elif [ "$usage_int" -ge 13 ]; then
    icon="${format_icons[1]}"
else
    icon="${format_icons[0]}"
fi
# #
# cpu_count=0
while read -r line; do
    if [[ $line =~ ^cpu[0-9] ]]; then
        echo "DASDASD${line}"
    fi
#         if [[ $cpu_count -gt 0 ]]; then
#             CPU=($line)
#             IDLE=${CPU[4]}
#             TOTAL=0
#             for VALUE in "${CPU[@]:1}"; do
#                 TOTAL=$((TOTAL + VALUE))
#             done
#
#             DIFF_IDLE=$((IDLE - PREV_IDLE))
#             DIFF_TOTAL=$((TOTAL - PREV_TOTAL))
#
#             if [ "$DIFF_TOTAL" -ne 0 ]; then
#                 CORE_USAGE=$(awk "BEGIN {printf \"%.2f\", 100 * ($DIFF_TOTAL - $DIFF_IDLE) / $DIFF_TOTAL}")
#             else 
#                 CORE_USAGE="0.00"
#             fi
#
#             tooltip+="Core $((cpu_count - 1)): $CORE_USAGE%\r"
#             PREV_TOTAL="$TOTAL"
#             PREV_IDLE="$IDLE"
#         fi
#         cpu_count=$((cpu_count + 1))
#     fi
done < /proc/stat
#
# # echo " $DIFF_USAGE% |$icon|"
# # echo -e {text: CPU Usage: $DIFF_USAGE% $icon}
echo "{\"text\":\" CPU Usage: $DIFF_USAGE% $icon\", \"tooltip\":\"$tooltip\", \"class\":\"cpu-custom\", }"

echo "$TOTAL $IDLE" > "$STATE_FILE"
