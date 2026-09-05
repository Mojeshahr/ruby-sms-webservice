#!/usr/bin/env ruby
# frozen_string_literal: true

# StatusById - وضعیت پیامک با شناسه‌هایی که متد ارسال برگردانده است.
#
# دسته‌ای بپرسید، نه یکی‌یکی. فاصله استعلام‌ها را هم کمتر از چند دقیقه
# نگذارید، وگرنه به خطای ۲۰ می‌خورید.
#
# جز کتابخانه استاندارد روبی به چیزی وابسته نیست. کپی کنید و در پروژه
# خودتان اجرا کنید.
#
#   PAYAM_RESAN_API_KEY=... ruby examples/v3/status-by-id.rb

# docs:start
require "json"
require "net/http"
require "uri"

payload = {
  "ApiKey" => ENV.fetch("PAYAM_RESAN_API_KEY"),
  "Ids" => [9903211, 9903212]
}

uri = URI("https://api.sms-webservice.com/api/V3/StatusById")

answer = Net::HTTP.start(uri.host, uri.port, use_ssl: true, open_timeout: 30, read_timeout: 30) do |http|
  http.post(uri.path, JSON.generate(payload), "Content-Type" => "application/json; charset=utf-8")
end

response = JSON.parse(answer.body)

unless response["Success"]
  abort("ناموفق. کد #{response['ErrorCode']}: #{response['Error']}")
end

# شرط را روی StatusCode بگذارید، نه روی متن Status. این پنج کد یعنی هنوز در
# راه است و باید بعداً دوباره استعلام کنید، نه اینکه دوباره بفرستید.
pending = [0, 1, 2, 3, 10]

response["Result"].each do |message|
  again = pending.include?(message["StatusCode"]) ? " (بعداً دوباره بپرسید)" : ""
  puts "#{message['Id']}: #{message['Status']}#{again}"
end
# docs:end
