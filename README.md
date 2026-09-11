<div align="center">

<a href="https://payam-resan.com">
  <img src=".github/assets/logo.svg" width="64" height="64" alt="پیام رسان">
</a>

<h1>نمونه‌کدهای Ruby وب‌سرویس پیام رسان</h1>

اتصال به وب‌سرویس <a href="https://payam-resan.com"><b>پنل پیامکی پیام رسان</b></a> با Ruby<br>
یک فایل قابل اجرا به‌ازای هر متد سرویس، بدون هیچ وابستگی

[![API](https://img.shields.io/badge/API-V3-0a7cbd)](https://payam-resan.com)
[![Ruby](https://img.shields.io/badge/Ruby-3.0%2B-cc342d)](https://ruby-lang.org)
[![Dependencies](https://img.shields.io/badge/dependencies-none-2ea44f)](#شروع-سریع)
[![License](https://img.shields.io/badge/license-MIT-6e7781)](LICENSE)

<b>فارسی</b> · <a href="README.en.md">English</a>

</div>

<sub>دنبال زبان دیگری هستید؟ همین نمونه‌ها برای زبان‌های دیگر هم در
[github.com/Mojeshahr](https://github.com/Mojeshahr) هست.</sub>

---

## شروع سریع

```bash
git clone https://github.com/Mojeshahr/ruby-sms-webservice.git
cd ruby-sms-webservice

export PAYAM_RESAN_API_KEY='123456-XXXXXXXXXXXXXXX'
export PAYAM_RESAN_SENDER='30004040'

ruby examples/v3/account-info.rb
```

نه `bundle install` لازم است و نه `Gemfile`. کتابخانه استاندارد خود روبی همه
چیز را دارد: `net/http` برای درخواست و `json` برای پاسخ.

با `account-info.rb` شروع کنید: چیزی ارسال نمی‌کند، اعتباری مصرف نمی‌کند، و
اگر جواب داد یعنی کلید و اتصال هر دو سالم‌اند.

## پیش از ارسال واقعی

یک سرور آزمایشی هست که مثل سرور عملیاتی جواب می‌دهد ولی پیامکی نمی‌فرستد و
اعتباری مصرف نمی‌کند. کافی است `V3` در نشانی را با `V3SandBox` عوض کنید. تنها
استثنا `TokenList` است که روی آن سرور پیاده نشده.

## متدها

<div dir="rtl">

| نمونه | متد | کار |
|---|---|---|
| [account-info.rb](examples/v3/account-info.rb) | `AccountInfo` | اعتبار و خطوط فعال |
| [send.rb](examples/v3/send.rb) | `Send` | ارسال ساده با `GET` |
| [send-bulk.rb](examples/v3/send-bulk.rb) | `SendBulk` | یک متن به چند گیرنده، با شناسه پی‌گیری |
| [send-multiple.rb](examples/v3/send-multiple.rb) | `SendMultiple` | متن جدا برای هر گیرنده |
| [token-list.rb](examples/v3/token-list.rb) | `TokenList` | فهرست قالب‌ها |
| [send-token-single.rb](examples/v3/send-token-single.rb) | `SendTokenSingle` | ارسال قالب به یک شماره |
| [send-token-single-get.rb](examples/v3/send-token-single-get.rb) | `SendTokenSingle` | همان، با `GET` |
| [send-token-multi.rb](examples/v3/send-token-multi.rb) | `SendTokenMulti` | یک قالب، چند گیرنده |
| [status-by-id.rb](examples/v3/status-by-id.rb) | `StatusById` | وضعیت با شناسه سامانه |
| [status-by-user-trace-id.rb](examples/v3/status-by-user-trace-id.rb) | `StatusByUserTraceId` | وضعیت با شناسه خودتان |
| [get-inbox.rb](examples/v3/get-inbox.rb) | `GetInbox` | پیامک‌های رسیده |

</div>

## چرا Gemfile نیست

هر فایل یک اسکریپت مستقل است و با `ruby <file>` اجرا می‌شود. نه گِمی نصب
می‌شود، نه `bundle exec` لازم است، و نه چیزی از این مخزن به فایل دیگری وصل
است. همین باعث می‌شود کپی‌کردن یک فایل داخل پروژه شما کافی باشد.

اگر روزی گِم نصب‌شدنی پیام رسان منتشر شود، در مخزن جداگانه خودش می‌آید و این
نمونه‌ها سر جایشان می‌مانند.

## استفاده در پروژه خودتان

نمونه‌ها عمداً به هیچ چیز این مخزن وابسته نیستند، پس کپی‌کردن فایل داخل پروژه
شما کافی است. اگر کلاینت HTTP خودتان را دارید، مثلاً Faraday یا HTTParty، لایه
`net/http` را نبرید و از هر فایل فقط بدنه درخواست و بررسی پاسخ را بردارید:

```ruby
response = HTTParty.post(
  "https://api.sms-webservice.com/api/V3/SendBulk",
  headers: { "Content-Type" => "application/json; charset=utf-8" },
  body: JSON.generate(
    "ApiKey" => ENV.fetch("PAYAM_RESAN_API_KEY"),
    "Sender" => 30004040,
    "Text" => "کد تأیید شما ۱۲۳۴۵۶ است",
    "Recipients" => [{ "Destination" => 9121112222, "UserTraceId" => 1001 }]
  )
).parsed_response

unless response["Success"]
  raise "پیامک ارسال نشد: #{response['Error']} (کد #{response['ErrorCode']})"
end
```

## چند نکته که وقت‌تان را می‌خرد

**کد وضعیت HTTP را نخوانید.** سرویس همیشه `200` برمی‌گرداند، حتی وقتی کلید
اشتباه است، پس `answer.code` چیزی ثابت نمی‌کند. تصمیم را از فیلد `Success`
بگیرید. هر نمونه اینجا همین کار را می‌کند.

**کلید را با `ENV.fetch` بخوانید، نه با `ENV[…]`.** شکل دوم وقتی متغیر تعریف
نشده باشد `nil` می‌دهد و شما یک درخواست با کلید خالی می‌فرستید و به‌جای پیام
روشن، خطای کلید نامعتبر می‌گیرید. `ENV.fetch` همان‌جا می‌ایستد.

**شماره گیرنده صفر ابتدایی ندارد.** یعنی `9121112222` یا با کد کشور
`989121112222`. شماره‌ای که با `9` یا `989` شروع نشود کد خطای `13` می‌گیرد.

**متن را دوباره encode نکنید.** در `send.rb` متد `URI.encode_www_form` خودش یک
بار این کار را می‌کند. اگر پیش از آن هم `encode_www_form_component` بزنید،
پیامک با نویسه‌های `%D8` به گوشی می‌رسد.

**برای هر گیرنده یک `UserTraceId` یکتا بفرستید.** بعد از یک timeout، این تنها
راه فهمیدن این است که پیامک ثبت شده یا نه.

## امنیت کلید

کلید یک راز است. در مخزن کد، در جاوااسکریپت مرورگر و در بسته اپلیکیشن موبایل
نباید قرار بگیرد. جای آن متغیر محیطی است، همان‌طور که همه نمونه‌ها می‌خوانندش.

اگر کلیدی لو رفت، از پنل یکی تازه بسازید. کلید حذف‌شده برنمی‌گردد.

## ساختار

<div dir="rtl">

| مسیر | چه چیزی دارد |
|---|---|
| `examples/v3/` | یک نمونه مستقل به‌ازای هر عملیات سرویس |
| `.env.example` | نمونه متغیرهای محیطی |

</div>

عدد `v3` در مسیر عمدی است. نسخه تازه سرویس یعنی پوشه `examples/v<n>/` تازه، و
پوشه موجود دست‌نخورده می‌ماند.

## مستندات و پشتیبانی

راهنمای کامل وب‌سرویس در [docs.payam-resan.com](https://docs.payam-resan.com)
است. توصیف ماشین‌خوان OpenAPI هم در
[sms-webservice-spec](https://github.com/Mojeshahr/sms-webservice-spec).

سؤال یا خطایی هست؟ [issue باز کنید](https://github.com/Mojeshahr/ruby-sms-webservice/issues)
یا با [پشتیبانی](https://payam-resan.com) تماس بگیرید.

## مجوز

منتشرشده با مجوز MIT. متن کامل در [`LICENSE`](LICENSE).

<br>
<div align="center">
  <sub>
    <img src=".github/assets/logo.svg" width="16" height="16" alt="" align="top">
    &nbsp;<b>پنل پیامکی پیام رسان - موج شهر</b>&nbsp;
    <picture>
      <source media="(prefers-color-scheme: dark)" srcset=".github/assets/mojeshahr-dark.svg">
      <img src=".github/assets/mojeshahr-light.svg" width="16" height="16" alt="" align="top">
    </picture>
  </sub>
  <br>
  <sub>
    <a href="https://payam-resan.com">payam-resan.com</a>
    &nbsp;·&nbsp;
    <a href="https://mojeshahr.ir">mojeshahr.ir</a>
  </sub>
</div>
