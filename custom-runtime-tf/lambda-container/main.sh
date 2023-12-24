#!/bin/bash

echo $events
RESPONSE="Hello from Container Runtime"
line="-------------------------------------"

#取得日期時間儲存為day變數
day=$(date +%Y-%m-%d_%H:%M)
i1=✳️
i2=✅
i3=✴️
i4=❌
i5=📋
i6=✔️
i7=☢️
i8=💎
i9=🍀
i10=⛔️
i11=🛎
i12=🔖
i13=⚡️
i14=❄️
i15=🍀
i16=🌿
i17=🌱
i18=☘️
i19=🌾
i20=💵

bot=https://api.telegram.org/bot
tk=""
gid=""

msg=$(printf '%s\n' $i5$day"定期消息:")
curl --data chat_id="$gid" --data-urlencode "text=$msg" "$bot$tk/sendMessage?parse_mode=HTML"
echo ""

curl -X 'GET' -Ss 'https://api.coingecko.com/api/v3/coins/markets?vs_currency=twd&ids=green-satoshi-token%2Cstepn%2Csolana%2Cbitcoin%2Cftx-token&price_change_percentage=1h%2C24h' -H 'accept: application/json' -o /tmp/.coin.txt
sleep 1
curl -X 'GET' -Ss 'https://api.coingecko.com/api/v3/coins/markets?vs_currency=usd&ids=green-satoshi-token%2Cstepn%2Csolana%2Cbitcoin%2Cftx-token&price_change_percentage=1h%2C24h' -H 'accept: application/json' -o /tmp/.coin_usd.txt

#---------------------------------------------------------------------------------------
name=$(cat /tmp/.coin.txt |jq -r '.'[0].'name')
c_price=$(cat /tmp/.coin.txt |jq -r '.'[0].'current_price')
c_price_usd=$(cat /tmp/.coin_usd.txt |jq -r '.'[0].'current_price')
h_24h=$(cat /tmp/.coin.txt |jq -r '.'[0].'high_24h')
l_24h=$(cat /tmp/.coin.txt |jq -r '.'[0].'low_24h')
ch_1h=$(cat /tmp/.coin.txt |jq -r '.'[0].'price_change_percentage_1h_in_currency')
ch_1h=$(echo ${ch_1h: 0:4})
ch_24h=$(cat /tmp/.coin.txt |jq -r '.'[0].'price_change_percentage_24h_in_currency')
ch_24h=$(echo ${ch_24h: 0:4})

msg=$(printf '%s\n' $i15"幣別:"$name $i11"價格(TWD):"$c_price $i20"價格(USD):"$c_price_usd  $i12"1H漲跌:"$ch_1h"%" $i12"24H漲跌:"$ch_24h"%"  $i13"24H最高:"$h_24h $i14"24H最低:"$l_24h )
echo ${msg}
curl --data chat_id="$gid" --data-urlencode "text=$msg" "$bot$tk/sendMessage?parse_mode=HTML"
sleep 5
#---------------------------------------------------------------------------------------

echo ""
echo ${RESPONSE}