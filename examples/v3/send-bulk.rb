#!/usr/bin/env ruby
# frozen_string_literal: true

# SendBulk - یک متن به چند گیرنده، هر کدام با شناسه پی‌گیری خودتان.
#
# روش پیشنهادی برای ارسال عملیاتی. کلید در بدنه درخواست می‌رود نه در نشانی،
# و برای هر گیرنده UserTraceId می‌پذیرد تا گزارش تحویل را بدون نگه‌داشتن Id
# سامانه بگیرید.
#
# جز کتابخانه استاندارد روبی به چیزی وابسته نیست. کپی کنید و در پروژه
# خودتان اجرا کنید.
#
#   PAYAM_RESAN_API_KEY=... PAYAM_RESAN_SENDER=... ruby examples/v3/send-bulk.rb

# docs:start
require "json"
require "net/http"
require "uri"

payload = {
  "ApiKey" => ENV.fetch("PAYAM_RESAN_API_KEY"),
  "Sender" => ENV.fetch("PAYAM_RESAN_SENDER").to_i,
  "Text" => "سفارش شما ثبت شد.",
  "Recipients" => [
    { "Destination" => 9121112222, "UserTraceId" => 1001 },
    { "Destination" => 9121113333, "UserTraceId" => 1002 }
  ]
}

uri = URI("https://api.sms-webservice.com/api/V3/SendBulk")

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
