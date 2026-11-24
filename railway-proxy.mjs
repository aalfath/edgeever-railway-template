// Railway terminates HTTPS at its edge and forwards plain HTTP to the
// container with X-Forwarded-Proto: https. EdgeEver derives Secure cookies,
// MCP origin checks and upload URLs from request.url, so report the public
// https URL to EdgeEver.
//
// Only the `url` property is overridden on the original Request object. Do
// not copy the request (`new Request(url, request)`): on Bun 1.3 that re-wraps
// the body stream, and a slow 20 MB upload through Railway's edge then used
// about 1 GB of memory and was OOM-killed at 0.5 GB.
const originalServe = Bun.serve;

const markPublicHttps = (request) => {
  const proto = request.headers.get("x-forwarded-proto")?.split(",", 1)[0]?.trim().toLowerCase();
  if (proto !== "https") return request;
  const url = new URL(request.url);
  if (url.protocol === "https:") return request;
  url.protocol = "https:";
  url.port = "";
  const publicUrl = url.href;
  Object.defineProperty(request, "url", { value: publicUrl, configurable: true });
  return request;
};

Bun.serve = function serveBehindRailwayProxy(options) {
  if (!options || typeof options.fetch !== "function") return originalServe.call(Bun, options);
  const appFetch = options.fetch;
  return originalServe.call(Bun, {
    ...options,
    fetch(request, server) {
      return appFetch.call(this, markPublicHttps(request), server);
    },
  });
};
