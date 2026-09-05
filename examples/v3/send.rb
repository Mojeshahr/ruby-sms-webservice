#!/usr/bin/env ruby
# frozen_string_literal: true

# Send - ساده‌ترین ارسال، یک متن به چند شماره با یک درخواست GET.
#
# برای آزمایش سریع خوب است. در محیط عملیاتی SendBulk را بردارید: کلید را از
# نشانی بیرون می‌برد و برای هر گیرنده شناسه پی‌گیری می‌پذیرد.
#
# جز کتابخانه استاندارد روبی به چیزی وابسته نیست. کپی کنید و در پروژه
# خودتان اجرا کنید.
#
#   PAYAM_RESAN_API_KEY=... PAYAM_RESAN_SENDER=... ruby examples/v3/send.rb

# docs:start
require "json"
require "net/http"
require "uri"

query = {
  "ApiKey" => ENV.fetch("PAYAM_RESAN_API_KEY"),
  "Sender" => ENV.fetch("PAYAM_RESAN_SENDER").to_i,
  "Text" => "کد تأیید شما ۱۲۳۴۵۶ است",
  "Recipients" => "9121112222,9121113333"
}

uri = URI("https://api.sms-webservice.com/api/V3/Send")

# encode_www_form دقیقاً یک بار encode می‌کند. اگر متن را خودتان هم پیش از
# این encode_www_form_component کنید، پیامک با نویسه‌های %D8 به گوشی می‌رسد.
uri.query = URI.encode_www_form(query)

answer = Net::HTTP.start(uri.host, uri.port, use_ssl: true, open_timeout: 30, read_timeout: 30) do |http|
  http.get(uri.request_uri)
end

response = JSON.parse(answer.body)

unless response["Success"]
  abort("ناموفق. کد #{response['ErrorCode']}: #{response['Error']}")
end

response["Result"].each do |message|
  puts "شناسه #{message['Id']}"
end
# docs:end
