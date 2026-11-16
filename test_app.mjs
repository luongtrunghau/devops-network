import { chromium, devices } from 'playwright';
import path from 'path';

(async () => {
  console.log('🤖 Khởi động robot kiểm thử giao diện đa thiết bị...');
  const browser = await chromium.launch();
  
  const filePath = `file://${path.resolve('app/index.html')}`;

  // ==========================================
  // 1. KIỂM TRA TRÊN MÁY TÍNH (DESKTOP)
  // ==========================================
  console.log('💻 Đang kiểm tra giao diện Desktop...');
  const desktopContext = await browser.newContext({ viewport: { width: 1280, height: 720 } });
  const desktopPage = await desktopContext.newPage();
  
  // Lắng nghe lỗi ngầm trong code (Console Error)
  let hasConsoleError = false;
  desktopPage.on('console', msg => {
    if (msg.type() === 'error') {
      console.error(`[Console Error phát hiện]: ${msg.text()}`);
      hasConsoleError = true;
    }
  });

  await desktopPage.goto(filePath);
  
  // Thử tương tác: Nhập tên miền và bấm kiểm tra
  await desktopPage.fill('#domainInput', 'github.com');
  await desktopPage.click('#checkBtn');
  await desktopPage.waitForSelector('#resultBox.active', { timeout: 5000 });
  console.log('✅ Giao diện và chức năng Desktop: HOẠT ĐỘNG TỐT');

  // ==========================================
  // 2. KIỂM THỬ TRÊN ĐIỆN THOẠI (MOBILE RESPONSIVE)
  // ==========================================
  console.log('📱 Đang kiểm tra giao diện di động (iPhone 13)...');
  const iPhone = devices['iPhone 13'];
  const mobileContext = await browser.newContext({ ...iPhone });
  const mobilePage = await mobileContext.newPage();

  await mobilePage.goto(filePath);
  
  // Kiểm tra xem trên màn hình nhỏ các nút bấm có bị tràn hay không
  const inputVisible = await mobilePage.isVisible('#domainInput');
  const btnVisible = await mobilePage.isVisible('#checkBtn');
  
  if (!inputVisible || !btnVisible) {
    console.error('❌ LỖI GIAO DIỆN: Các thành phần bị ẩn hoặc tràn màn hình trên mobile!');
    process.exit(1);
  }
  console.log('✅ Giao diện Mobile Responsive: ĐẠT');

  if (hasConsoleError) {
    console.error('❌ Phát hiện lỗi JavaScript ngầm trong trang web!');
    process.exit(1);
  }

  await browser.close();
  console.log('🎉 TẤT CẢ BÀI TEST ĐA THIẾT BỊ ĐÃ VƯỢT QUA HOÀN HẢO!');
})();