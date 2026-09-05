#!/usr/bin/env ruby
# frozen_string_literal: true

# AccountInfo - اعتبار باقی‌مانده و خطوط فعال حساب.
#
# سبک‌ترین متد سرویس و بهترین راه آزمودن کلید: چیزی ارسال نمی‌کند، اعتباری
# مصرف نمی‌کند، و حتی با اعتبار صفر هم جواب می‌دهد.
#
# جز کتابخانه استاندارد روبی به چیزی وابسته نیست. کپی کنید و در پروژه
# خودتان اجرا کنید.
#
#   PAYAM_RESAN_API_KEY=... ruby examples/v3/account-info.rb

# docs:start
require "json"
require "net/http"
require "uri"

payload = { "ApiKey" => ENV.fetch("PAYAM_RESAN_API_KEY") }

uri = URI("https://api.sms-webservice.com/api/V3/AccountInfo")

answer = Net::HTTP.start(uri.host, uri.port, use_ssl: true, open_timeout: 30, read_timeout: 30) do |http|
  http.post(uri.path, JSON.generate(payload), "Content-Type" => "application/json; charset=utf-8")
end

response = JSON.parse(answer.body)

unless response["Success"]
  abort("ناموفق. کد #{response['ErrorCode']}: #{response['Error']}")
end

puts "اعتبار: #{response['Result']['Credit']}"

response["Result"]["AvailableSenders"].each do |line|
  puts "خط: #{line}"
end
# docs:end
