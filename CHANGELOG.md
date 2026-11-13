# Changelog

This project follows [Semantic Versioning 2.0.0](https://semver.org).

## 0.0.9 (2026-11-13): patch

- **Fix:** `URLRequest.asCurlCommand` percent-encoded the URL a second time, so a URL that was
  already encoded produced a curl command for a *different* URL:
  `https://e.com/a%20b?q=1#frag` printed as `curl 'https://e.com/a%2520b?q=1%23frag'`. It now
  prints the URL exactly as `absoluteString` gives it, and escapes only `'` so the single-quoted
  shell string stays valid.
- **Output change:** the command text differs for URLs containing `%`, `#` or `'`. It is
  unchanged for other URLs (both existing snapshots are byte-identical). This is a patch release
  because the property is documented as a debugging aid that reproduces the request, and the old
  output did not reproduce it. If you compare its text in your own snapshot tests, re-record them
  for such URLs.
- A TLA+ model of the request helpers is checked on CI (`formal/`).
