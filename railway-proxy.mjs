// Railway terminates HTTPS at its edge and forwards plain HTTP to the
// container with X-Forwarded-Proto: https. EdgeEver derives Secure cookies,
// MCP origin checks and upload URLs from the request URL, so rewrite the URL
// scheme to https before EdgeEver sees the request.
const originalServe = Bun.serve;

const toPublicRequest = (request) => {
  const proto = request.headers.get("x-forwarded-proto")?.split(",", 1)[0]?.trim().toLowerCase();
  if (proto !== "https") return request;
  const url = new URL(request.url);
  if (url.protocol === "https:") return request;
  url.protocol = "https:";
  url.port = "";
  return new Request(url, request);
};

Bun.serve = function serveBehindRailwayProxy(options) {
  if (!options || typeof options.fetch !== "function") return originalServe.call(Bun, options);
  const appFetch = options.fetch;
  return originalServe.call(Bun, {
    ...options,
    fetch(request, server) {
      return appFetch.call(this, toPublicRequest(request), server);
    },
  });
};
