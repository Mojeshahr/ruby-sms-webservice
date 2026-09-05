#!/usr/bin/env ruby
# frozen_string_literal: true

# SendTokenSingle با GET - همان ارسال قالب، با ورودی در نشانی.
#
# برای آزمایش دستی مناسب است، برای محیط عملیاتی نه: در GET هم کلید حساب و هم
# مقدار رمز یک‌بارمصرف داخل نشانی می‌نشینند و در لاگ وب‌سرور و هدر Referer
# ثبت می‌شوند. واریانت POST را بردارید.
#
# جز کتابخانه استاندارد روبی به چیزی وابسته نیست. کپی کنید و در پروژه
# خودتان اجرا کنید.
#
#   PAYAM_RESAN_API_KEY=... ruby examples/v3/send-token-single-get.rb

# docs:start
require "json"
require "net/http"
require "uri"

query = {
  "ApiKey" => ENV.fetch("PAYAM_RESAN_API_KEY"),
  "TemplateKey" => "verifycode",
  "Destination" => 9121112222,
  "p1" => "123456"
}

uri = URI("https://api.sms-webservice.com/api/V3/SendTokenSingle")
uri.query = URI.encode_www_form(query)

answer = Net::HTTP.start(uri.host, uri.port, use_ssl: true, open_timeout: 30, read_timeout: 30) do |http|
  http.get(uri.request_uri)
end

response = JSON.parse(answer.body)

unless response["Success"]
  abort("ناموفق. کد #{response['ErrorCode']}: #{response['Error']}")
end

response["Result"].each do |message|
  puts "شناسه #{message['Id']}، متن نهایی: #{message['FinalText']}"
end
# docs:end
