#!/usr/bin/env ruby
# frozen_string_literal: true

# StatusByUserTraceId - وضعیت پیامک با شناسه‌هایی که خودتان داده‌اید.
#
# اگر UserTraceId را کلید رکورد پایگاه داده خودتان بگذارید، دیگر لازم نیست Id
# سامانه را ذخیره کنید. این متد راه امن تشخیص ارسال تکراری هم هست: بعد از قطع
# ارتباط، اول اینجا بپرسید ثبت شده یا نه.
#
# جز کتابخانه استاندارد روبی به چیزی وابسته نیست. کپی کنید و در پروژه
# خودتان اجرا کنید.
#
#   PAYAM_RESAN_API_KEY=... ruby examples/v3/status-by-user-trace-id.rb

# docs:start
require "json"
require "net/http"
require "uri"

payload = {
  "ApiKey" => ENV.fetch("PAYAM_RESAN_API_KEY"),
  "UserTraceIds" => [1001, 1002]
}

uri = URI("https://api.sms-webservice.com/api/V3/StatusByUserTraceId")

answer = Net::HTTP.start(uri.host, uri.port, use_ssl: true, open_timeout: 30, read_timeout: 30) do |http|
  http.post(uri.path, JSON.generate(payload), "Content-Type" => "application/json; charset=utf-8")
end

response = JSON.parse(answer.body)

unless response["Success"]
  abort("ناموفق. کد #{response['ErrorCode']}: #{response['Error']}")
end

response["Result"].each do |message|
  # کد ۸ یعنی این شناسه در حساب شما نیست. بعد از یک timeout، همین یعنی
  # ارسال ثبت نشده و می‌توانید با خیال راحت دوباره بفرستید.
  if message["StatusCode"] == 8
    puts "#{message['UserTraceId']}: ثبت نشده"
    next
  end

  puts "#{message['UserTraceId']}: #{message['Status']}"
end
# docs:end
