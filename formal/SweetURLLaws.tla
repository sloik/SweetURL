----------------------------- MODULE SweetURLLaws -----------------------------
(* Finite model of Sources/SweetURL: URL.asRequest / asRequest(method:) /    *)
(* queryValues and URLRequest.set(body/method/header/field) / asCurlCommand. *)
(* Abstractions: URLs are 3 symbols ("plain", "pct" = contains an existing   *)
(* %-escape, "hash" = contains a fragment #); header names are {"A","B"};    *)
(* header values {"v1","v2"}; bodies {"b1","b2"}; methods {"GET","get",      *)
(* "POST"} (lowercase "get" exercises the uppercased() comparison); query    *)
(* items are (name, value) over tiny sets with "nil" meaning no value.       *)
(* Foundation's percent-encoding is modelled only as far as it matters: the  *)
(* identity on plain text, and escaping "%" and "#" (urlQueryAllowed).       *)
EXTENDS Naturals, Sequences, FiniteSets

CONSTANTS Mutant    \* "none" for the real semantics, otherwise a seeded bug

Methods == {"GET", "get", "POST"}
HKeys   == {"A", "B"}
HVals   == {"v1", "v2"}
Absent  == "absent"
Bodies  == {"nobody", "b1", "b2"}
Urls    == {"plain", "pct", "hash", "quote"}   \* "quote" = contains a single quote
Headers == [HKeys -> HVals \cup {Absent}]
Reqs    == [method : Methods, headers : Headers, body : Bodies, url : Urls]

\* URLExtensions.swift / URLRequestExtensions.swift
NoHeaders == [k \in HKeys |-> Absent]
AsRequest(u)           == [method |-> "GET", headers |-> NoHeaders, body |-> "nobody", url |-> u]
AsRequestM(u, m)       == [AsRequest(u) EXCEPT !.method = m]
SetBody(r, b)          == [r EXCEPT !.body = b]
SetMethod(r, m)        == [r EXCEPT !.method = m]
SetHeader(r, k, v)     ==
  [r EXCEPT !.headers =
     IF Mutant = "set_header_clears_others"
     THEN [j \in HKeys |-> IF j = k THEN v ELSE Absent]
     ELSE [r.headers EXCEPT ![k] = v]]
SetField(r, name, v)   == SetHeader(r, name, v)   \* set(field:) = set(header: canonicalName, value:)

\* queryValues: nil when the URL has no query; else non-nil values with that name
QNames == {"a", "b"}
QVals  == {"x", "y", "nil"}
QItems == [name : QNames, val : QVals]
QSeqs  == {<<>>} \cup {<<i>> : i \in QItems} \cup {<<i, j>> : i, j \in QItems}
Queries == [has : {FALSE}, items : {<<>>}] \cup [has : {TRUE}, items : QSeqs]
RECURSIVE QV(_, _)
QV(items, n) ==
  IF items = <<>> THEN <<>>
  ELSE (IF (Mutant = "queryvalues_ignores_name" \/ Head(items).name = n) /\ Head(items).val # "nil"
        THEN <<Head(items).val>> ELSE <<>>) \o QV(Tail(items), n)
QueryValues(q, n) == IF q.has THEN [none |-> FALSE, vals |-> QV(q.items, n)]
                     ELSE [none |-> TRUE, vals |-> <<>>]

\* asCurlCommand: lines = url, optional -X, headers sorted by key descending, optional -d
\* 0.0.9: the URL line is absoluteString verbatim; only ' is shell-escaped.
Enc(u) ==
  IF Mutant = "legacy_double_encode" /\ u = "pct"  THEN "pct_escaped"    \* pre-0.0.9: %20 -> %2520
  ELSE IF Mutant = "legacy_double_encode" /\ u = "hash" THEN "hash_escaped"   \* #frag -> %23frag
  ELSE IF u = "quote" THEN "quote_shell_escaped"
  ELSE u
Rank(k) == IF k = "B" THEN 2 ELSE 1   \* string order of the header names: "A" < "B"
Up(m)  == IF m = "get" THEN "GET" ELSE m
HLine(r, k) == IF r.headers[k] = Absent THEN <<>>
               ELSE <<[kind |-> "H", a |-> k, b |-> r.headers[k]]>>
CurlLines(r) ==
  <<[kind |-> "url", a |-> Enc(r.url), b |-> ""]>>
  \o (IF Up(r.method) # "GET" THEN <<[kind |-> "X", a |-> r.method, b |-> ""]>> ELSE <<>>)
  \o HLine(r, "B") \o HLine(r, "A")
  \o (IF r.body # "nobody" THEN <<[kind |-> "d", a |-> r.body, b |-> ""]>> ELSE <<>>)

VARIABLES r, q, k1, k2, v1, v2
vars == <<r, q, k1, k2, v1, v2>>
Init == /\ r \in Reqs /\ q \in Queries
        /\ k1 \in HKeys /\ k2 \in HKeys /\ v1 \in HVals /\ v2 \in HVals
Next == UNCHANGED vars
Spec == Init /\ [][Next]_vars

TypeOK == r \in Reqs /\ q \in Queries /\ k1 \in HKeys /\ k2 \in HKeys
          /\ v1 \in HVals /\ v2 \in HVals

AsRequestIsGet ==
  \A u \in Urls : AsRequest(u).method = "GET" /\ AsRequest(u).headers = NoHeaders
                  /\ AsRequest(u).body = "nobody" /\ AsRequest(u).url = u
AsRequestMethodOverrides ==
  \A u \in Urls, m \in Methods :
    AsRequestM(u, m).method = m /\ AsRequestM(u, m).url = u /\ AsRequestM(u, m).body = "nobody"
SetMethodOnlyChangesMethod ==
  \A m \in Methods : LET n == SetMethod(r, m) IN
    n.method = m /\ n.headers = r.headers /\ n.body = r.body /\ n.url = r.url
SetBodyOnlyChangesBody ==
  \A b \in Bodies : LET n == SetBody(r, b) IN
    n.body = b /\ n.headers = r.headers /\ n.method = r.method /\ n.url = r.url
SetHeaderOverwrites == SetHeader(r, k1, v1).headers[k1] = v1
SetHeaderPreservesOthers ==
  \A j \in HKeys : j # k1 => SetHeader(r, k1, v1).headers[j] = r.headers[j]
SetHeaderKeepsRest ==
  LET n == SetHeader(r, k1, v1) IN n.method = r.method /\ n.body = r.body /\ n.url = r.url
SetHeaderIdempotent == SetHeader(SetHeader(r, k1, v1), k1, v1) = SetHeader(r, k1, v1)
SetHeaderLastWins == SetHeader(SetHeader(r, k1, v1), k1, v2).headers[k1] = v2
SetHeadersCommuteOnDistinctKeys ==
  k1 # k2 => SetHeader(SetHeader(r, k1, v1), k2, v2) = SetHeader(SetHeader(r, k2, v2), k1, v1)
SetFieldIsSetHeader == SetField(r, k1, v1) = SetHeader(r, k1, v1)

CurlStartsWithURL == CurlLines(r)[1].kind = "url" /\ CurlLines(r)[1].a = Enc(r.url)
CurlEncodingIdentityOnPlain == Enc("plain") = "plain"
\* already-encoded URLs pass through unchanged; only a single quote is shell-escaped
CurlURLVerbatim == r.url # "quote" => CurlLines(r)[1].a = r.url
CurlQuoteShellEscaped == r.url = "quote" => CurlLines(r)[1].a = "quote_shell_escaped"
CurlMethodLineIffNotGet ==
  (\E i \in 1..Len(CurlLines(r)) : CurlLines(r)[i].kind = "X") <=> (Up(r.method) # "GET")
CurlOneLinePerHeader ==
  Cardinality({i \in 1..Len(CurlLines(r)) : CurlLines(r)[i].kind = "H"})
    = Cardinality({k \in HKeys : r.headers[k] # Absent})
CurlHeadersDescending ==
  \A i, j \in 1..Len(CurlLines(r)) :
    (i < j /\ CurlLines(r)[i].kind = "H" /\ CurlLines(r)[j].kind = "H")
      => Rank(CurlLines(r)[i].a) > Rank(CurlLines(r)[j].a)
CurlBodyLineIffBody ==
  (\E i \in 1..Len(CurlLines(r)) : CurlLines(r)[i].kind = "d") <=> (r.body # "nobody")
CurlBodyIsLast ==
  r.body # "nobody" => CurlLines(r)[Len(CurlLines(r))].kind = "d"
CurlGetPlainHasOneLine ==
  (Up(r.method) = "GET" /\ r.headers = NoHeaders /\ r.body = "nobody") => Len(CurlLines(r)) = 1

QueryNoQueryIsNil == ~q.has => QueryValues(q, "a").none
QueryValuesFilterByName ==
  \A n \in QNames : q.has =>
    \A i \in 1..Len(QueryValues(q, n).vals) :
      \E j \in 1..Len(q.items) : q.items[j].name = n /\ q.items[j].val = QueryValues(q, n).vals[i]
QueryValuesCountMatches ==
  \A n \in QNames : q.has =>
    Len(QueryValues(q, n).vals)
      = Cardinality({j \in 1..Len(q.items) : q.items[j].name = n /\ q.items[j].val # "nil"})
QueryValuesPreserveOrder ==
  \A n \in QNames : q.has /\ Len(q.items) = 2
    /\ q.items[1].name = n /\ q.items[2].name = n
    /\ q.items[1].val # "nil" /\ q.items[2].val # "nil"
    => QueryValues(q, n).vals = <<q.items[1].val, q.items[2].val>>
=============================================================================
