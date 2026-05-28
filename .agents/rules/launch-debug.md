---
trigger: model_decision
---

# Launch Debug Session

When the user requests to "debug/start debug/launch app/relaunch app", you MUST use the following command and then STOP. Do not perform any additional actions or research unless specifically asked.

```bash
flutter run --debug --dart-define-from-file=config/app_client.public.json
```
