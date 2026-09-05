<div align="center">

<a href="https://payam-resan.com">
  <img src=".github/assets/logo.svg" width="64" height="64" alt="Payam Resan">
</a>

<h1>Ruby examples for the Payam Resan SMS web service</h1>

Talk to the <a href="https://payam-resan.com"><b>Payam Resan SMS panel</b></a> from Ruby<br>
One runnable file per API method, with no dependencies

[![API](https://img.shields.io/badge/API-V3-0a7cbd)](https://payam-resan.com)
[![Ruby](https://img.shields.io/badge/Ruby-3.0%2B-cc342d)](https://ruby-lang.org)
[![Dependencies](https://img.shields.io/badge/dependencies-none-2ea44f)](#quick-start)
[![License](https://img.shields.io/badge/license-MIT-6e7781)](LICENSE)

<a href="README.md">فارسی</a> · <b>English</b>

</div>

<sub>Looking for another language? The same examples exist for the others at
[github.com/Mojeshahr](https://github.com/Mojeshahr).</sub>

---

## Quick start

```bash
git clone https://github.com/Mojeshahr/ruby-sms-webservice.git
cd ruby-sms-webservice

export PAYAM_RESAN_API_KEY='123456-XXXXXXXXXXXXXXX'
export PAYAM_RESAN_SENDER='30004040'

ruby examples/v3/account-info.rb
```

No `bundle install` and no `Gemfile`. Ruby's standard library has everything
these need: `net/http` for the request and `json` for the answer.

Start with `account-info.rb`. It sends nothing, spends no credit, and if it
answers then both the key and the connection are fine.

## Before sending anything real

There is a sandbox server that answers exactly like production but sends no
message and spends no credit. Swap `V3` for `V3SandBox` in the URL. The one
exception is `TokenList`, which the sandbox does not implement.

## The methods

| Example | Method | What it does |
|---|---|---|
| [account-info.rb](examples/v3/account-info.rb) | `AccountInfo` | Credit and active lines |
| [send.rb](examples/v3/send.rb) | `Send` | Simple send over `GET` |
| [send-bulk.rb](examples/v3/send-bulk.rb) | `SendBulk` | One text to many recipients, with tracking ids |
| [send-multiple.rb](examples/v3/send-multiple.rb) | `SendMultiple` | A separate text per recipient |
| [token-list.rb](examples/v3/token-list.rb) | `TokenList` | The account's templates |
| [send-token-single.rb](examples/v3/send-token-single.rb) | `SendTokenSingle` | Send a template to one number |
| [send-token-single-get.rb](examples/v3/send-token-single-get.rb) | `SendTokenSingle` | The same, over `GET` |
| [send-token-multi.rb](examples/v3/send-token-multi.rb) | `SendTokenMulti` | One template, many recipients |
| [status-by-id.rb](examples/v3/status-by-id.rb) | `StatusById` | Status by the service's id |
| [status-by-user-trace-id.rb](examples/v3/status-by-user-trace-id.rb) | `StatusByUserTraceId` | Status by your own id |
| [get-inbox.rb](examples/v3/get-inbox.rb) | `GetInbox` | Messages people sent to your lines |

## Why there is no Gemfile

Each file is a standalone script that runs with `ruby <file>`. Nothing to
install, no `bundle exec`, and no file in this repository reaching into
another. That is what makes copying one file into your project enough.

If an installable gem is published one day it will live in its own repository,
and these examples will stay as they are.

## Using this in your own project

Every example is deliberately free of any dependency on this repository, so
copying the file into your project is enough. If you already have an HTTP
client such as Faraday or HTTParty, leave the `net/http` layer behind and take
only the request body and the response check:

```ruby
response = HTTParty.post(
  "https://api.sms-webservice.com/api/V3/SendBulk",
  headers: { "Content-Type" => "application/json; charset=utf-8" },
  body: JSON.generate(
    "ApiKey" => ENV.fetch("PAYAM_RESAN_API_KEY"),
    "Sender" => 30004040,
    "Text" => "Your verification code is 123456",
    "Recipients" => [{ "Destination" => 9121112222, "UserTraceId" => 1001 }]
  )
).parsed_response

unless response["Success"]
  raise "SMS not sent: #{response['Error']} (code #{response['ErrorCode']})"
end
```

## Things that will save you time

**Do not read the HTTP status code.** The service answers `200` to everything,
including a wrong key, so `answer.code` proves nothing. Decide on the `Success`
field. Every example here does.

**Read the key with `ENV.fetch`, not `ENV[…]`.** The second form returns `nil`
when the variable is unset, so you send a request with an empty key and get an
invalid-key error instead of a clear message. `ENV.fetch` stops right there.

**Recipient numbers carry no leading zero.** Use `9121112222`, or
`989121112222` with the country code. A number that does not start with `9` or
`989` returns error code `13`.

**Do not encode the text twice.** In `send.rb`, `URI.encode_www_form` already
does it once. Call `encode_www_form_component` beforehand and the message
arrives full of `%D8`.

**Send a unique `UserTraceId` per recipient.** After a timeout it is the only
way to learn whether the message was registered.

## Key safety

The key is a secret. It does not belong in a code repository, in browser
JavaScript, or in a mobile app bundle. It belongs in an environment variable,
which is where every example here reads it from.

If a key leaks, issue a new one from the panel. A deleted key never comes back.

## Layout

| Path | What it holds |
|---|---|
| `examples/v3/` | One self-contained example per service operation |
| `.env.example` | The environment variables the examples read |

The `v3` in the path is deliberate. A new service version means a new
`examples/v<n>/`, with the existing folder left alone.

## Documentation and support

The full guide is at [docs.payam-resan.com](https://docs.payam-resan.com). The
machine-readable OpenAPI description is in
[sms-webservice-spec](https://github.com/Mojeshahr/sms-webservice-spec).

## License

MIT. Full text in [`LICENSE`](LICENSE).
