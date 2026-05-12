import os
import sys
import json
import requests

def send_apk(apk_path):
    config_path = 'config/api_keys.json'
    
    if not os.path.exists(config_path):
        print(f"Error: {config_path} not found.")
        sys.exit(1)
        
    if not os.path.exists(apk_path):
        print(f"Error: APK file {apk_path} not found.")
        sys.exit(1)

    with open(config_path, 'r') as f:
        config = json.load(f)

    bot_token = config.get('TELEGRAM_BOT_TOKEN')
    chat_id = config.get('TELEGRAM_CHAT_ID')

    if not bot_token or not chat_id:
        print("Error: TELEGRAM_BOT_TOKEN or TELEGRAM_CHAT_ID missing in config.")
        sys.exit(1)

    url = f"https://api.telegram.org/bot{bot_token}/sendDocument"
    
    import time
    timestamp = time.strftime("%Y%m%d-%H%M%S")
    base_name = os.path.basename(apk_path)
    new_name = f"{timestamp}_{base_name}"
    
    print(f"Sending {apk_path} as {new_name} to {chat_id}...")
    
    with open(apk_path, 'rb') as apk_file:
        files = {'document': (new_name, apk_file)}
        data = {'chat_id': chat_id}
        
        try:
            response = requests.post(url, data=data, files=files)
            response.raise_for_status()
            print("Successfully sent APK via Telegram.")
        except requests.exceptions.HTTPError as e:
            if response.status_code == 413:
                print("Error: File too large (Telegram Bot API limit is 50MB).")
            else:
                print(f"Error sending APK: {e}")
                print(f"Response: {response.text}")
            sys.exit(1)
        except Exception as e:
            print(f"An unexpected error occurred: {e}")
            sys.exit(1)

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python send_apk.py <path_to_apk>")
        sys.exit(1)
    
    send_apk(sys.argv[1])
