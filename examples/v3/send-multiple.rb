#!/usr/bin/env ruby
# frozen_string_literal: true

# SendMultiple - متن و خط فرستنده جدا برای هر گیرنده.
#
# برای پیام‌های شخصی‌سازی‌شده که با یک قالب ثابت پوشش داده نمی‌شوند. برخلاف
# SendBulk، اینجا Text و Sender در سطح هر گیرنده تعریف می‌شوند.
#
# جز کتابخانه استاندارد روبی به چیزی وابسته نیست. کپی کنید و در پروژه
# خودتان اجرا کنید.
#
#   PAYAM_RESAN_API_KEY=... PAYAM_RESAN_SENDER=... ruby examples/v3/send-multiple.rb

# docs:start
require "json"
require "net/http"
require "uri"

sender = ENV.fetch("PAYAM_RESAN_SENDER").to_i

payload = {
  "ApiKey" => ENV.fetch("PAYAM_RESAN_API_KEY"),
  "Recipients" => [
    {
      "Sender" => sender,
      "Destination" => 9121112222,
      "Text" => "آقای محمدی، سفارش شما ارسال شد.",
      "UserTraceId" => 1001
    },
    {
      "Sender" => sender,
      "Destination" => 9121113333,
      "Text" => "خانم رضایی، سفارش شما ارسال شد.",
      "UserTraceId" => 1002
    }
  ]
}

uri = URI("https://api.sms-webservice.com/api/V3/SendMultiple")

answer = Net::HTTP.start(uri.host, uri.port, use_ssl: true, open_timeout: 30, read_timeout: 30) do |http|
  http.post(uri.path, JSON.generate(payload), "Content-Type" => "application/json; charset=utf-8")
end

response = JSON.parse(answer.body)

unless response["Success"]
  abort("ناموفق. کد #{response['ErrorCode']}: #{response['Error']}")
end

response["Result"].each do |message|
  puts "#{message['UserTraceId']} => شناسه #{message['Id']}"
end
# docs:end
