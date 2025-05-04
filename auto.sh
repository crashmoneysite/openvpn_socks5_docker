#!/bin/bash

# Telegram bot info
BOT_TOKEN="7556548451:AAGcgF5snAeR_hJzq7m18QQz567ezBkozJM"
CHAT_ID="352188296"
API_URL="https://api.telegram.org/bot$BOT_TOKEN/sendMessage"

send_telegram_message() {
  local message="$1"
  local hostname=$(hostname)
  curl -s -G "$API_URL" \
    --data-urlencode "chat_id=$CHAT_ID" \
    --data-urlencode "text=$hostname: $message" > /dev/null
}


start_script() {
  while true; do
    sudo docker exec openvpn_holder /etc/openvpn/launch.sh
    sleep 5

    # Get IP via OpenVPN proxy
    IP=$(curl --socks5 127.0.0.1:9050 --max-time 5 -s ipinfo.io/ip)

    if [[ -n "$IP" ]]; then
      echo "Proxy is working. IP: $IP"
      send_telegram_message "Proxy is working. IP: $IP."

      sleep 2

      # Try to activate WARP up to 3 times
      for attempt in {1..3}; do
        WARP_OUTPUT=$(docker exec openvpn_holder warp y)
        echo "$WARP_OUTPUT"

        if echo "$WARP_OUTPUT" | grep -q "WireProxy is connected"; then
          echo "WARP connected successfully."

          # Check if WARP proxy is working
          WARP_IP=$(curl --socks5 127.0.0.1:8086 --max-time 5 -s ipinfo.io/ip)

          if [[ -n "$WARP_IP" ]]; then
            echo "WARP proxy is working. IP: $WARP_IP"
            send_telegram_message "WARP IP: $WARP_IP  restarting xray..."
            sudo systemctl restart xray
            SLEEP_TIME=$(curl -s https://raw.githubusercontent.com/crashmoneysite/openvpn_socks5_docker/refs/heads/master/sleep_time.txt)
            SLEEP_TIME=${SLEEP_TIME//[^0-9]/}  # پاک‌سازی غیر عددی‌ها

           if [[ -z "$SLEEP_TIME" ]]; then
            SLEEP_TIME=1800  # مقدار پیش‌فرض در صورت خطا
           fi

           echo "Sleeping for $SLEEP_TIME seconds..."
           sleep "$SLEEP_TIME"
            break
          else
            echo "WARP proxy check failed. Restarting script..."
            send_telegram_message "WARP connection failed."
            break  # Exit loop and retry
          fi
        else
          echo "WARP connection failed, retrying ($attempt)..."
          sleep 2
        fi

        # After 3 failed attempts
        if [[ $attempt -eq 3 ]]; then
          echo "WARP failed after 3 attempts. Restarting process..."
          send_telegram_message "WARP failed after 3 attempts. Restarting process..."
        fi
      done

    else
      echo "Proxy check failed. Retrying OpenVPN launch..."
      send_telegram_message "Proxy check failed. Retrying OpenVPN launch..."
      # Retry immediately
    fi
  done
}

# Start the loop
start_script
