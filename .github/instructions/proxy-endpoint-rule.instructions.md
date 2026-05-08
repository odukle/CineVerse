## Proxy Endpoint Rule (CRITICAL)

- **Mandatory Allowlist Update**: Whenever a new TMDb or proxy endpoint is added or consumed (e.g., adding a new category or data type), you **MUST** update the `ALLOWED_STATIC_PATHS` or regex patterns in `infra/tmdb-proxy-worker/src/index.js`.
- **Automatic Deployment**: After updating the worker code, you **MUST** deploy it immediately by running `npm run deploy` (or `npx wrangler deploy`) in the `infra/tmdb-proxy-worker/` directory. Do not wait for user prompting.
- **Live Verification**: A task involving a new endpoint is **NOT COMPLETE** until you have verified it by hitting the deployed worker URL (e.g., using `read_url_content`) to ensure the proxy is correctly forwarding the request.
- **Fail-Safe**: If a deployment fails due to credentials, inform the user immediately, but the code update to `index.js` remains a mandatory part of the PR/Task.
