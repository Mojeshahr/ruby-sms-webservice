#!/usr/bin/env ruby
# frozen_string_literal: true

# SendTokenMulti - یک قالب، چند گیرنده، مقادیر متفاوت.
#
# پارامترها اینجا آرایه‌اند، نه p1 تا p10. درایه اول به {1} می‌نشیند، دومی به
# {2} و همین‌طور تا آخر: ترتیب از شماره جای‌گاه می‌آید، نه از جایی که در متن
# قالب دیده می‌شود.
#
# جز کتابخانه استاندارد روبی به چیزی وابسته نیست. کپی کنید و در پروژه
# خودتان اجرا کنید.
#
#   PAYAM_RESAN_API_KEY=... ruby examples/v3/send-token-multi.rb

# docs:start
require "json"
require "net/http"
require "uri"

# قالب نمونه: «مرسوله شما از {2} تحویل پست شد. بارکد مرسوله پستی: {1}»
payload = {
  "ApiKey" => ENV.fetch("PAYAM_RESAN_API_KEY"),
  "TemplateKey" => "postcode",
  "Recipients" => [
    {
      "Destination" => 9121112222,
      "UserTraceId" => 1001,
      "Parameters" => ["BARCODE-AAA", "شیراز"]
    },
    {
      "Destination" => 9121113333,
      "UserTraceId" => 1002,
      "Parameters" => ["BARCODE-BBB", "تبریز"]
    }
  ]
}

uri = URI("https://api.sms-webservice.com/api/V3/SendTokenMulti")

answer = Net::HTTP.start(uri.host, uri.port, use_ssl: true, open_timeout: 30, read_timeout: 30) do |http|
  http.post(uri.path, JSON.generate(payload), "Content-Type" => "application/json; charset=utf-8")
end

response = JSON.parse(answer.body)

unless response["Success"]
  abort("ناموفق. کد #{response['ErrorCode']}: #{response['Error']}")
end

response["Result"].each do |message|
  puts "#{message['UserTraceId']} => #{message['FinalText']}"
end
# docs:end
