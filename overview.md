# Deploy and Host EdgeEver on Railway

EdgeEver is an open-source, AI-native note-taking app and knowledge base, positioned as an Evernote and Obsidian alternative. It keeps the classic three-pane layout (notebooks, note list, editor) and adds rich notes (tables, mind maps, diagrams, posters), instant sync for its web, desktop and mobile apps, a web clipper and a built-in remote MCP server for AI agents.

## About Hosting EdgeEver

This template runs the official EdgeEver v2.31.2 container (Bun with SQLite) as one service, built from a public GitHub repo that pins the image by version and digest. Everything the app stores, the SQLite database, the credential encryption key and uploaded images and attachments, lives on a Railway volume at `/data`, so notes survive redeploys and restarts. The admin password is generated at deploy time, so there is nothing to type in. Railway's HTTPS edge is passed through to the app, so session cookies are Secure and the MCP endpoint accepts your public URL. The service has a health check on `/api/health` and restarts on failure.

## Common Use Cases

* A private, self-hosted replacement for Evernote or Obsidian Sync, with the same notes on the web, desktop and phone
* A personal or small-team knowledge base with notebooks, tags, tables, mind maps and web clippings
* Giving AI agents such as Claude Code, Codex or Cursor read or write access to your notes over MCP, limited per token and per notebook

## Dependencies for EdgeEver Hosting

* One Railway service built from the `aalfath/edgeever-railway-template` GitHub repo (official `ghcr.io/tianma-if/edgeever` image)
* One Railway volume mounted at `/data` (SQLite database, secrets file and attachments)

### Deployment Dependencies

* EdgeEver source and releases: https://github.com/tianma-if/edgeever/releases
* EdgeEver Docker guide: https://github.com/tianma-if/edgeever/blob/main/docs/deploy-docker.md
* MCP client guide: https://github.com/tianma-if/edgeever/blob/main/docs/mcp-guide.md
* Template repo: https://github.com/aalfath/edgeever-railway-template

### Implementation Details

**After deploy:** open the service's public URL and sign in as `admin` with the password from the service's `EDGE_EVER_AUTH_PASSWORD` variable (Variables tab). It is only the first-login password: change it under Profile, and add users or two-factor sign-in there too. The username comes from `EDGE_EVER_AUTH_USERNAME`; change it before the first login if you want another one.

**Clients:** point the EdgeEver desktop or mobile apps and the browser clipper at `https://YOUR-DOMAIN`.

**MCP for AI agents:** create a token under Profile → API / MCP, then add the server to your client, for example:

```json
{
  "mcpServers": {
    "edgeever": {
      "url": "https://YOUR-DOMAIN/mcp",
      "headers": { "Authorization": "Bearer YOUR-TOKEN" }
    }
  }
}
```

**AI features** are optional: add your own provider and key in the app's AI settings. Keys are stored encrypted on the volume.

**Resources:** idle use is about 80 MB of RAM, and attachments of 95 MB uploaded in the app stayed under 0.25 GB, so it runs on Railway's Free plan (0.5 GB). Back up with the app's ZIP export, or snapshot the volume.

**Updates:** the repo pins an exact EdgeEver release. When it moves to a new release, Railway shows an "update available" notice on your project; read the repo's CHANGELOG, then apply it. EdgeEver runs its database migrations on start. The in-app or `install.sh` auto-updater does not apply on Railway.

## Why Deploy EdgeEver on Railway?

<!-- Recommended: Keep this section as shown below -->
Railway is a singular platform to deploy your infrastructure stack. Railway will host your infrastructure so you don't have to deal with configuration, while allowing you to vertically and horizontally scale it.

By deploying EdgeEver on Railway, you are one step closer to supporting a complete full-stack application with minimal burden. Host your servers, databases, AI agents, and more on Railway.
<!-- End recommended section -->
