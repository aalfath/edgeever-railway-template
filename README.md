[![Deploy on Railway](https://railway.com/button.svg)](https://railway.com/new/template/edgeever-3?utm_medium=integration&utm_source=button&utm_campaign=edgeever)

# EdgeEver on Railway

One-click Railway template for [EdgeEver](https://github.com/tianma-if/edgeever), an open-source, AI-native note-taking app (Evernote/Obsidian alternative) with rich notes, instant sync, a web clipper and a built-in MCP server.

## What it deploys

| Service | What it does |
|---|---|
| **EdgeEver** | Official `ghcr.io/tianma-if/edgeever:v2.31.2` image (pinned by digest), Bun + SQLite, on port `8787`, health check `/api/health`, restart on failure. Volume at `/data` holds the SQLite database, the credential encryption secret and all attachments. |

The wrapper in this repo is small:

- `Dockerfile`: pins the upstream image and adds the two files below.
- `railway-start.sh`: hands the root-owned Railway volume to the image's `bun` user (UID 1000), then drops privileges; refuses to start with no password or with `EDGE_EVER_ALLOW_UNAUTHENTICATED=true`; the server is PID 1, so any crash exits non-zero and Railway restarts it.
- `railway-proxy.mjs`: Railway ends HTTPS at its edge and forwards plain HTTP. This preload reports the public `https://` URL to EdgeEver (from `X-Forwarded-Proto`), so session cookies are `Secure` and MCP's origin check accepts your domain.

## Variables

| Variable | Default | Notes |
|---|---|---|
| `EDGE_EVER_AUTH_PASSWORD` | generated (24 chars) | First admin password. Copy it from the Variables tab, sign in, then change it under Profile. |
| `EDGE_EVER_AUTH_USERNAME` | `admin` | First admin username. |
| `PORT` | `8787` | Port the app listens on and Railway routes to. |

Nothing has to be typed in at deploy time. AI providers and keys are optional and set inside the app.

## After deploy

1. Open the public URL and sign in as `admin` with `EDGE_EVER_AUTH_PASSWORD`.
2. Change the password under **Profile**, and add two-factor sign-in or more users if you like.
3. For AI agents: **Profile → API / MCP** → create a token, then use `https://YOUR-DOMAIN/mcp` with `Authorization: Bearer <token>` (streamable HTTP).

## Resources

Measured on Railway with a 0.5 GB / 1 vCPU limit: about 65–80 MB of RAM idle, under 0.25 GB while uploading a 95 MB attachment the way the app does (8 MB parts). It fits Railway's Free plan. Single-request uploads of tens of MB through the API use more memory; the apps and web UI split large files, so they don't.

## Updates

This repo pins an exact EdgeEver release by tag and digest. When we move it to a newer release on `main`, Railway shows an "update available" notice on projects deployed from this template; read [CHANGELOG.md](CHANGELOG.md) first (breaking changes are listed first). EdgeEver applies its own database migrations on start. Back up first (in-app ZIP export, or a volume snapshot): a rollback does not undo migrations.

EdgeEver's own `install.sh` auto-updater is not used on Railway.

## Licence

EdgeEver is AGPL-3.0 (© its authors). This wrapper only adds deployment files.
