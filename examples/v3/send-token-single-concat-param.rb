#!/usr/bin/env ruby
# frozen_string_literal: true

# SendTokenSingleConcatParam - ارسال قالب با مقدارهای جداشده با ; در رشته p.
#
# مسیر معمول رمز یک‌بارمصرف. خط فرستنده ورودی ندارد؛ سامانه آن را از روی خود
# قالب برمی‌دارد. همین واریانت POST را به کار ببرید، نه GET: در GET هم کلید
# حساب و هم خود رمز داخل نشانی و لاگ وب‌سرور می‌نشینند.
#
# جز کتابخانه استاندارد روبی به چیزی وابسته نیست. کپی کنید و در پروژه
# خودتان اجرا کنید.
#
#   PAYAM_RESAN_API_KEY=... ruby examples/v3/send-token-single-concat-param.rb

# docs:start
require "json"
require "net/http"
require "uri"

payload = {
  "ApiKey" => ENV.fetch("PAYAM_RESAN_API_KEY"),
  "TemplateKey" => "postcode",
  "Destination" => 9121112222,
  # مقدار اول برای {1} و مقدار دوم برای {2} است.
  "p" => "BARCODE-AAA;شیراز"
}

uri = URI("https://www.payam-resan.com/api/V3/SendTokenSingleConcatParam")

answer = Net::HTTP.start(uri.host, uri.port, use_ssl: true, open_timeout: 30, read_timeout: 30) do |http|
  http.post(uri.path, JSON.generate(payload), "Content-Type" => "application/json; charset=utf-8")
end

response = JSON.parse(answer.body)

unless response["Success"]
  abort("ناموفق. کد #{response['ErrorCode']}: #{response['Error']}")
end

# این متد UserTraceId در ورودی ندارد، پس در پاسخ nil برمی‌گردد. اگر شناسه
# پی‌گیری لازم دارید، SendTokenMulti را حتی برای یک گیرنده هم می‌شود به کار برد.
response["Result"].each do |message|
  puts "شناسه #{message['Id']} از خط #{message['Sender']}"
  puts "متن نهایی: #{message['FinalText']}"
end
# docs:end
