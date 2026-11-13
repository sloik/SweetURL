# Formal model (TLA+)

`SweetURLLaws.tla` is a finite TLA+ model of the public semantics of `Sources/SweetURL`:
`URL.asRequest`, `asRequest(method:)`, `queryValues(_:)` and `URLRequest.set(body:/method:/header:/field:)`
and `asCurlCommand`.

## Abstractions (Foundation types)

URLs, strings and `Data` are abstracted to small enumerated sets: three URL symbols
(`plain`, `pct` = contains an existing percent-escape, `hash` = contains a `#`), header names `{A, B}`,
header values `{v1, v2}`, bodies `{b1, b2}`, methods `{GET, get, POST}` (lowercase `get` exercises
`method.uppercased()`), and query items over names `{a, b}` and values `{x, y, nil}`. Percent-encoding
is modelled only as the identity on plain text and escaping of `%` and `#`. `URLRequest` is a record
(`set` returns a copy, so purity is by construction).

| Invariant | Swift API it abstracts |
|---|---|
| `TypeOK` | domain of the model variables |
| `AsRequestIsGet`, `AsRequestMethodOverrides` | `URL.asRequest`, `asRequest(method:)` |
| `SetMethodOnlyChangesMethod`, `SetBodyOnlyChangesBody` | `set(method:)`, `set(body:)` |
| `SetHeaderOverwrites`, `SetHeaderPreservesOthers`, `SetHeaderKeepsRest`, `SetHeaderIdempotent`, `SetHeaderLastWins`, `SetHeadersCommuteOnDistinctKeys` | `set(header:value:)` |
| `SetFieldIsSetHeader` | `set(field:)` delegates to `set(header:value:)` |
| `CurlStartsWithURL`, `CurlEncodingIdentityOnPlain`, `CurlURLVerbatim`, `CurlQuoteShellEscaped` | first line of `asCurlCommand`: the URL as-is, only `'` shell-escaped |
| `CurlMethodLineIffNotGet` | `-X` line only for non-GET (case-insensitive) |
| `CurlOneLinePerHeader`, `CurlHeadersDescending` | `-H` lines, sorted by key descending |
| `CurlBodyLineIffBody`, `CurlBodyIsLast`, `CurlGetPlainHasOneLine` | `-d` line |
| `QueryNoQueryIsNil`, `QueryValuesFilterByName`, `QueryValuesCountMatches`, `QueryValuesPreserveOrder` | `URL.queryValues(_:)` |

Not modelled: HTTP header-name case-insensitivity of `URLRequest.allHTTPHeaderFields`, UTF-8
decoding failure of the body (then no `-d` line), shell escaping of `'` in headers and body,
`HTTPField.Name.canonicalName` mapping.

## Findings

- **Fixed in 0.0.9:** `asCurlCommand` encoded the URL a second time with
  `addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)`, which escapes `%` and `#`, so
  `https://e.com/a%20b?q=1#frag` printed as `https://e.com/a%2520b?q=1%23frag`. It now uses
  `absoluteString` unchanged and only shell-escapes `'`. The old bug is the `legacy_double_encode`
  mutant (caught by `CurlURLVerbatim`).

## Non-vacuity

Each `SweetURLLaws.<mutant>.cfg` seeds one bug through the `Mutant` constant and names the
invariant that must catch it (`\* EXPECT_VIOLATION: ...`):

- `set_header_clears_others`: `set(header:)` drops other headers (caught by `SetHeaderPreservesOthers`).
- `queryvalues_ignores_name`: `queryValues` skips the name filter (caught by `QueryValuesCountMatches`).

`run_tlc.sh` fails if a mutant passes.

## Running

```sh
TLA_JAR=/path/to/tla2tools-1.7.4.jar formal/run_tlc.sh   # needs Java 11+
```

The script checks the jar's SHA-256 against the pinned tla2tools 1.7.4. CI runs it on a
self-hosted Oracle ARM64 runner, only on pushes to the default branch or by manual dispatch
(`.github/workflows/oracle-tla.yml`). The Swift build and tests stay on hosted macOS.

## Limits

The model describes the *intended* semantics, read by hand from the Swift sources. It does not
prove the Swift code conforms; the XCTest suite covers the code. If the Swift behaviour
changes, update the model in the same PR.
