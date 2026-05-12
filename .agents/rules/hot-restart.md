---
trigger: model_decision
---

# Hot Restart Instruction

When the user requests a "hot restart", you MUST:
1. Identify the command ID of the currently running `flutter run` process (using `command_status` or by checking recent history).
2. Use the `send_command_input` tool to send the character `R` (uppercase) to that command.
3. Confirm to the user that the hot restart signal has been sent.

Do not perform any other actions or restart the app from scratch unless the hot restart fails.
