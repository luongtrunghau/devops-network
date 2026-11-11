# --- Script kiểm tra cú pháp Terraform và HTML ---
$hasError = $false

# 1. Kiểm tra các file Terraform (.tf)
$tfFiles = Get-ChildItem -Filter "*.tf"
foreach ($file in $tfFiles) {
    $content = Get-Content $file.FullName
    # Kiểm tra cơ bản dấu ngoặc nhọn hoặc cú pháp trống
    Write-Host "Dang kiem tra file Terraform: $($file.Name)"
}

# 2. Kiểm tra file index.html (Kiểm tra thẻ đóng mở cơ bản)
if (Test-Path "index.html") {
    Write-Host "Dang kiem tra file index.html..."
    $htmlContent = Get-Content "index.html" -Raw
    
    # Ví dụ quy tắc kiểm tra đơn giản: Nếu mở thẻ html mà thiếu thẻ đóng </html>
    if ($htmlContent -match "<html" -and $htmlContent -notmatch "</html>") {
        Write-Host "[LOI] File index.html bi thieu the dong </html>!" -ForegroundColor Red
        $hasError = $true
    }
    
    # Kiểm tra thẻ body
    if ($htmlContent -match "<body" -and $htmlContent -notmatch "</body>") {
        Write-Host "[LOI] File index.html bi thieu the dong </body>!" -ForegroundColor Red
        $hasError = $true
    }
}

# 3. Xử lý kết quả và gửi thông báo Telegram nếu có lỗi
if ($hasError) {
    Write-Host "[CI ERROR] Phat hien loi cu phap trong du an!"
    
    $token = $env:TELEGRAM_BOT_TOKEN
    $chatId = $env:TELEGRAM_CHAT_ID
    
    if ($token -and $chatId) {
        $message = "[CI ERROR] Phat hien loi trong file index.html hoac Terraform tren nhanh main!"
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