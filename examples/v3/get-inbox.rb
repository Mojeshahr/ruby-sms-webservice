#!/usr/bin/env ruby
# frozen_string_literal: true

# GetInbox - پیامک‌هایی که کاربران به خطوط حساب شما فرستاده‌اند.
#
# این یک استعلام است، نه webhook: سامانه چیزی به سرور شما نمی‌فرستد و باید
# خودتان دوره‌ای صدایش بزنید. فاصله را کمتر از چند دقیقه نگذارید، وگرنه به
# خطای ۲۰ می‌خورید.
#
# جز کتابخانه استاندارد روبی به چیزی وابسته نیست. کپی کنید و در پروژه
# خودتان اجرا کنید.
#
#   PAYAM_RESAN_API_KEY=... ruby examples/v3/get-inbox.rb

# docs:start
require "json"
require "net/http"
require "uri"

payload = { "ApiKey" => ENV.fetch("PAYAM_RESAN_API_KEY") }

uri = URI("https://api.sms-webservice.com/api/V3/GetInbox")

answer = Net::HTTP.start(uri.host, uri.port, use_ssl: true, open_timeout: 30, read_timeout: 30) do |http|
  http.post(uri.path, JSON.generate(payload), "Content-Type" => "application/json; charset=utf-8")
end

response = JSON.parse(answer.body)

unless response["Success"]
  abort("ناموفق. کد #{response['ErrorCode']}: #{response['Error']}")
end

response["Result"].each do |sms|
  # نام فیلد فرستنده در خود سرویس Form است، نه From. دنبال From نگردید.
  puts "#{sms['Time']}  #{sms['Form']} -> #{sms['To']}: #{sms['Text']}"
end
# docs:end
