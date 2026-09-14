# Working with this repository

You are looking at runnable Ruby examples for the **Payam Resan** SMS web
service (`api.sms-webservice.com`, API V3), an Iranian SMS provider. Someone is
probably asking you to add SMS to their project.

Copy the example that matches the method, adapt it, and keep the rules below.
They are not style preferences — each one is a bug that this service produces if
you ignore it.

## Start here

```bash
export PAYAM_RESAN_API_KEY='123456-XXXXXXXXXXXXXXX'
ruby examples/v3/account-info.rb
```

`account-info.rb` sends nothing, spends no credit, and answers even on a zero
balance, so run it first to prove the key and the connection work.

Ruby 3.0 or newer. Standard library only — `net/http`, `json` and `uri` — so
there is no `Gemfile`, no gemspec and no `bundle install`. If the project
already runs Faraday or HTTParty, keep the payload and the `Success` check and
replace only the transport.

## Rule 1: `use_ssl: true` is load-bearing

`URI("https://…")` on its own does not give you TLS through `Net::HTTP.start`.
Drop the flag and the request goes out in plaintext to port 443 — which, on the
`GET` methods, puts the account key on the wire in the clear.

```ruby
Net::HTTP.start(uri.host, uri.port, use_ssl: true, open_timeout: 30, read_timeout: 30) do |http|
  http.post(uri.path, JSON.generate(payload), "Content-Type" => "application/json; charset=utf-8")
end
```

Note also which URI part each verb wants: POST takes `uri.path`, GET takes
`uri.request_uri`. Use `path` on a GET and the query string is silently dropped.

## Rule 2: `Success`, never the HTTP status

The service answers `200` to everything, including a wrong key, an empty account
and a malformed body. `answer.code` proves nothing.

```ruby
response = JSON.parse(answer.body)

unless response["Success"]
  abort("ناموفق. کد #{response['ErrorCode']}: #{response['Error']}")
end

response["Result"].each do |message|
  puts "#{message['UserTraceId']} => شناسه #{message['Id']}"
end
```

`abort` writes to stderr and exits `1`, which is what a reader wants when the
file is run from a shell. In a Rails app, raise instead.

`ErrorCode` is only meaningful when `Success` is false.

## Rule 3: string keys, both directions

Request hashes use `"ApiKey" => …`, not the `ApiKey:` symbol shorthand. The
service is case-sensitive about its PascalCase names, and a symbol key would
serialise as `apikey` or `ApiKey` depending on how you wrote it.

On the way back, `JSON.parse` hands you string keys and the examples never pass
`symbolize_names: true`. Read `message["Id"]`, not `message[:Id]`.

## Rule 4: `ENV.fetch`, never `ENV[…]`

```ruby
ENV.fetch("PAYAM_RESAN_API_KEY")
```

`ENV["…"]` returns `nil` when the variable is unset, so you send a request with
an empty key and get an invalid-key error instead of a clear message.
`ENV.fetch` stops right there.

The key never leaves the server. Never write it into source, and never let it
reach a browser — if the front end is JavaScript, it must call **their** Rails
endpoint, which calls this.

Avoid `send.rb` and `send-token-single-get.rb` in production. Those are the
`GET` methods, where the key sits in the URL and lands in the web server log and
the `Referer` header.

## Rule 5: no exception handling is built in

There is no `rescue` anywhere in these examples, on purpose — they are scripts.
A DNS failure, a TLS problem or a read timeout raises out of
`Net::HTTP.start` before the `Success` check is ever reached.

In real code, catch those separately from a `Success: false`. A timeout means
you do not know whether the message was sent — see Rule 7 before retrying.

## Rule 6: pick the right method

| The user wants | Use | File |
|---|---|---|
| one text to many people | `SendBulk` | `send-bulk.rb` |
| a different text per person | `SendMultiple` | `send-multiple.rb` |
| a one-time password or code | `SendTokenSingle` | `send-token-single.rb` |
| a template to many people | `SendTokenMulti` | `send-token-multi.rb` |
| delivery status | `StatusByUserTraceId` | `status-by-user-trace-id.rb` |
| balance and sender lines | `AccountInfo` | `account-info.rb` |

**A one-time password goes through a template**, not free text — that is the
usual route for OTP, and the template fixes the sender line, which is why
`SendTokenSingle` takes no `Sender`. `token-list.rb` lists the account's
templates; `Status` `2` means approved and sendable, `1` awaiting review, `3`
rejected.

## Rule 7: phone numbers, the 99 cap, and `UserTraceId`

The service wants `9121112222` or `989121112222`. Users type `09121112222` or
`+989121112222`. Normalise before sending, or you get error `13`. Ninety-nine
recipients per request is the ceiling for `SendBulk`, `SendMultiple` and
`SendTokenMulti`.

Always send a `UserTraceId` — the user's own database id. After a timeout or
error `100`, resending blind may send twice; `StatusByUserTraceId` is the only
safe way to learn whether the message was registered. `StatusCode` of `8` there
means the id is not in the account, so it is safe to send again.

`SendTokenSingle` is the exception: it has no such input, so its `UserTraceId`
comes back null. If a trace id is needed for an OTP, use `SendTokenMulti` with a
single recipient.

`JSON.generate` emits UTF-8 as it is, so Persian text goes out readable and
needs no re-encoding pass. `URI.encode_www_form` encodes the query exactly once
— call `encode_www_form_component` on the text beforehand as well and the
message arrives full of `%D8`.

## Rule 8: know which errors are worth retrying

These never succeed on retry — fix the cause; retrying only burns the rate limit
until the account hits error `20`:

`1`, `2`, `3`, `6`, `8`, `9`, `10`, `11`, `12`, `13`, `14`, `19`

`19` is an empty balance; `10` means the caller's IP is not on the account's
allowlist. Treat any unknown code the way you treat `100`: unclear outcome,
check with `StatusByUserTraceId` before resending.

## Rule 9: delivery status is a poll, not a callback

Status codes `0`, `1`, `2`, `3` and `10` mean still in flight — query again
later, and not more often than every few minutes or you will hit error `20`.
Everything else is final. Branch on `StatusCode`, never on the `Status` text,
which is Persian prose meant for humans and can change.

## Rule 10: `GetInbox` consumes what it returns

The service hands over each incoming message **once**. Never call it from a
controller: every request consumes unread messages permanently. It belongs in a
scheduled job that writes straight to the database.

The sender field is called `Form`, not `From`. That is the service's spelling,
not a typo in the example.

## Testing without spending credit

Replace `V3` with `V3SandBox` in the URL. No message is sent and no credit is
spent. `TokenList` is the one exception the sandbox does not implement.

The sandbox is a simulator, not a mirror of the account: credit is always
`1234567`, sender lines are invented, and **it accepts any key**. Success there
proves nothing about the user's real key.

## Where the authoritative answers are

- Method reference and error tables: <https://docs.payam-resan.com>
- Machine-readable OpenAPI: <https://github.com/Mojeshahr/sms-webservice-spec>

If an installable gem is published one day it will live in its own repository,
and these examples will stay as they are.

If the spec and these examples ever disagree, the spec wins — report it as a bug
rather than guessing.
