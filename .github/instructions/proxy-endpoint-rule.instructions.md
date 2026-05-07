## Proxy Endpoint Rule

- Whenever a new TMDb or proxy endpoint is added, enabled, or consumed by the app, update the Cloudflare worker route allowlist if needed and deploy the worker before considering the task complete.
- Any change that introduces a new proxied endpoint must include live verification against the deployed worker URL, not just local code changes.
