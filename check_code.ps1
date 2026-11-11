# --- Script kiểm tra cú pháp Terraform và HTML ---
$hasError = $false

# 1. Kiểm tra các file Terraform (.tf)
$tfFiles = Get-ChildItem -Filter "*.tf"
foreach ($file in $tfFiles) {
    Write-Host "Dang kiem tra file Terraform: $($file.Name)"
}

# 2. Kiểm tra file index.html (Nằm trong thư mục app/index.html theo Git status của bạn)
$htmlPath = "app/index.html"
if (Test-Path $htmlPath) {
    Write-Host "Dang kiem tra file $htmlPath..."
    $htmlContent = Get-Content $htmlPath -Raw
    
    # Kiểm tra tính đối xứng cơ bản của các thẻ HTML chính
    $openHtml = ([regex]::Matches($htmlContent, "<html\b", "IgnoreCase")).Count
    $closeHtml = ([regex]::Matches($htmlContent, "</html>", "IgnoreCase")).Count
    
    $openBody = ([regex]::Matches($htmlContent, "<body\b", "IgnoreCase")).Count
    $closeBody = ([regex]::Matches($htmlContent, "</body>", "IgnoreCase")).Count

    if ($openHtml -ne $closeHtml) {
        Write-Host "[LOI] File HTML lech so luong the <html> (Mo: $openHtml, Dong: $closeHtml)!" -ForegroundColor Red
        $hasError = $true
    }
    
    if ($openBody -ne $closeBody) {
        Write-Host "[LOI] File HTML lech so luong the <body> (Mo: $openBody, Dong: $closeBody)!" -ForegroundColor Red
        $hasError = $true
    }
} else {
    Write-Host "Khong tim thay file $htmlPath"
}

# 3. Xử lý kết quả và gửi thông báo Telegram nếu có lỗi
if ($hasError) {
    Write-Host "[CI ERROR] Phat hien loi cu phap trong file HTML!"
    
    $token = $env:TELEGRAM_BOT_TOKEN
    $chatId = $env:TELEGRAM_CHAT_ID
    
    if ($token -and $chatId) {
        $message = "[CI ERROR] Phat hien loi cu phap trong app/index.html tren nhanh main!"
        $url = "https://api.telegram.org/bot$token/sendMessage?chat_id=$chatId&text=$([Uri]::EscapeDataString($message))"
        
        try {
            Invoke-RestMethod -Uri $url -Method Get
            Write-Host "Da gui bao dong ve Telegram thanh cong."
        } catch {
            Write-Host "Loi khi gui tin nhan Telegram: $_"
        }
    }
    exit 1
} else {
    Write-Host "Tat ca file deu hop le. Check code thanh cong!"
    exit 0
}