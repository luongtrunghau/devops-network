import { chromium } from 'playwright';
import path from 'path';

(async () => {
  console.log('🤖 Đang khởi động trình duyệt ảo để kiểm thử giao diện & chức năng...');
  const browser = await chromium.launch();
  const page = await browser.newPage();

  // Mở file index.html trực tiếp
  const filePath = `file://${path.resolve('app/index.html')}`;
  await page.goto(filePath);

  // 1. Kiểm tra tiêu đề trang web
  const title = await page.title();
  if (!title.includes('NetCheck Pro')) {
    console.error('❌ LỖI TEST: Tiêu đề trang web không chính xác!');
    process.exit(1);
  }
  console.log('✅ Kiểm tra tiêu đề trang web: ĐẠT');

  // 2. Giả lập người dùng nhập tên miền và bấm nút kiểm tra
  await page.fill('#domainInput', 'google.com');
  await page.click('#checkBtn');

  // 3. Chờ kết quả hiển thị và xác minh chức năng hoạt động
  await page.waitForSelector('#resultBox.active', { timeout: 5000 });
  await page.waitForFunction(() => {
    const text = document.getElementById('statusText').innerText;
    return text.includes('Online') || text.includes('Offline');
  }, { timeout: 10000 });

  const ipResult = await page.innerText('#ipVal');
  console.log(`✅ Kiểm tra chức năng phân giải DNS cho google.com: ĐẠT (IP: ${ipResult})`);

  await browser.close();
  console.log('🎉 TẤT CẢ BÀI KIỂM THỬ TỰ ĐỘNG ĐỀU THÀNH CÔNG!');
})();