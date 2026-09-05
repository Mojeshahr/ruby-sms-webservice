#!/usr/bin/env ruby
# frozen_string_literal: true

# TokenList - قالب‌های حساب، با کلید و متن و وضعیت تأییدشان.
#
# برای پیدا کردن TemplateKey که متدهای ارسال قالب لازم دارند. این متد هم مثل
# AccountInfo از بررسی اعتبار معاف است.
#
# جز کتابخانه استاندارد روبی به چیزی وابسته نیست. کپی کنید و در پروژه
# خودتان اجرا کنید.
#
#   PAYAM_RESAN_API_KEY=... ruby examples/v3/token-list.rb

# docs:start
require "json"
require "net/http"
require "uri"

payload = { "ApiKey" => ENV.fetch("PAYAM_RESAN_API_KEY") }

uri = URI("https://api.sms-webservice.com/api/V3/TokenList")

answer = Net::HTTP.start(uri.host, uri.port, use_ssl: true, open_timeout: 30, read_timeout: 30) do |http|
  http.post(uri.path, JSON.generate(payload), "Content-Type" => "application/json; charset=utf-8")
end

response = JSON.parse(answer.body)

unless response["Success"]
  abort("ناموفق. کد #{response['ErrorCode']}: #{response['Error']}")
end

response["Result"].each do |template|
  sendable = template["Status"] == 2 ? "قابل ارسال" : "قابل ارسال نیست"
  puts "#{template['Key']} (#{sendable}): #{template['TextTemplate']}"
end
# docs:end
