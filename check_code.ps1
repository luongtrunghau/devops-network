$botToken = "9282153038:AAHfmVZA6umXxR9eMA8GpPtF0rziGze124U"
$chatId   = "8189104771"

$filePath = "D:\DevOps-Network\app\index.html"
$content = Get-Content $filePath -Joi "`n"

if ($content -notmatch "</html>") {
    Write-Host "[CI ERROR] Phat hien loi cu phap! Dang gui bao dong Telegram..." -ForegroundColor Red
    
    $message = "[CI/CD BUILD FAILED]`n`nDev: Hau Luong`nFile: app/index.html`nLoi: Thieu hoac sai the dong </html>!`nGoi y: Kiem tra lai file code."

    $url = "https://api.telegram.org/bot$botToken/sendMessage"
    $body = @{
        chat_id    = $chatId
        text       = $message
    }
    Invoke-RestMethod -Uri $url -Method Post -Body $body | Out-Null

    exit 1
} else {
    Write-Host "[CI SUCCESS] Ma nguon cua Dev sach se!" -ForegroundColor Green
}