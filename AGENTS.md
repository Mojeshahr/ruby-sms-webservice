# Agent guide

Runnable Ruby examples for the Payam Resan SMS web service. One file per API
method, and every file has to work on its own.

## Rule one: no dependencies, and no Gemfile either

An example runs with a stock Ruby and nothing else: `net/http` and `json` are
both in the standard library, so there is no `httparty`, no `faraday`, and no
`bundle install`. A reader copies the file into their project and it works. The
moment a gem is needed, the example stops being an example and becomes a
project.

There is deliberately no `Gemfile` and no gemspec. Each file is a plain script
that runs with

```bash
ruby examples/v3/send-bulk.rb
```

The same rule rules out helpers from this repository. There is no shared client
module here and there should not be one: a method defined in `utils/` means
nothing to somebody reading the file on the documentation site.

## Rule two: string keys on both sides

Request hashes use `"ApiKey" => …`, not the `ApiKey:` symbol shorthand. The
service is case-sensitive about its PascalCase names, and `JSON.parse` hands
back string keys anyway, so both halves of every example read the same way. A
file that builds with symbols and reads with strings teaches a mismatch.

`JSON.generate` emits UTF-8 as-is, so Persian text goes out readable rather
than as `ک` escapes. Nothing here needs a re-encoding pass on top of it.

## Rule three: the examples are the documentation

Each file carries `# docs:start` and `# docs:end`. The region between them is
lifted verbatim into the method's page on docs.payam-resan.com, so it is read by
people who have never seen this repository.

Two consequences:

- **Full-line comments are stripped** when the region is lifted. Anything the
  reader must see has to be code. The `Success` check is an `unless`, not a
  note.
- The file name matches the reference page slug exactly: `send-bulk.rb`,
  `status-by-user-trace-id.rb`. A path with two variants gets two files, the
  plain name for `POST` and a `-get` suffix for `GET`.

The full contract lives in the `handbook` repository, section `docs-site`, file
`code-samples.md`.

## Rule four: check Success, never the status code

The service answers `200` to everything, including a wrong key and an empty
account, so `answer.code` proves nothing:

```ruby
unless response["Success"]
  abort("ناموفق. کد #{response['ErrorCode']}: #{response['Error']}")
end
```

`abort` writes to stderr and exits `1`, which is what a reader wants when the
file is run from a shell.

## Rule five: a version is a folder

A new service version means a new `examples/v<n>/`. No file inside an existing
version folder is moved or renamed; older versions still have users.

## Secrets

The key comes from `PAYAM_RESAN_API_KEY` in the environment, read with
`ENV.fetch` so a missing variable fails loudly instead of sending `nil`. No key,
no real phone number and no customer name goes into a file here, not even a dead
one. Example numbers are `9121112222` upward and the example key is
`123456-XXXXXXXXXXXXXXX`.

## Layout

| Path | What it holds |
|---|---|
| `examples/v3/` | one self-contained file per service operation |
| `.env.example` | the environment variables the examples read |

## Before every commit

```bash
for f in examples/v3/*.rb; do ruby -c "$f" >/dev/null || echo "FAILED $f"; done
```

Point them at `api/V3SandBox/` before running one for real, so no message goes
out.

## Git

Semantic messages, `type(scope): subject`, with no explanatory body and no
attribution trailer. Commits here are authored as Payam Resan.
