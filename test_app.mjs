import { chromium, devices } from 'playwright';
import path from 'path';

(async () => {
  console.log('🤖 Khởi động robot kiểm thử giao diện đa thiết bị...');
  const browser = await chromium.launch();
  const filePath = `file://${path.resolve('app/index.html')}`;

  try {
    // 1. KIỂM TRA TRÊN MÁY TÍNH (DESKTOP)
    console.log('💻 Đang kiểm tra giao diện Desktop...');
    const desktopContext = await browser.newContext({ viewport: { width: 1280, height: 720 } });
    const desktopPage = await desktopContext.newPage();

    let consoleErrors = [];
    desktopPage.on('console', msg => {
      if (msg.type() === 'error') {
        consoleErrors.push(msg.text());
      }
    });

    await desktopPage.goto(filePath);
    await desktopPage.fill('#domainInput', 'github.com');
    await desktopPage.click('#checkBtn');

    try {
      await desktopPage.waitForSelector('#resultBox.active', { timeout: 4000 });
    } catch (e) {
      await desktopPage.screenshot({ path: 'error_screenshot.png', fullPage: true });
      throw new Error('Lỗi chức năng Desktop: Bấm nút nhưng khung kết quả không hiện!');
    }

    if (consoleErrors.length > 0) {
      await desktopPage.screenshot({ path: 'error_screenshot.png', fullPage: true });
      throw new Error(`Lỗi ngầm JavaScript: ${consoleErrors[0]}`);
    }

    // 2. KIỂM THỬ TRÊN ĐIỆN THOẠI (MOBILE RESPONSIVE)
    console.log('📱 Đang kiểm tra giao diện di động (iPhone 13)...');
    const iPhone = devices['iPhone 13'];
    const mobileContext = await browser.newContext({ ...iPhone });
    const mobilePage = await mobileContext.newPage();

    await mobilePage.goto(filePath);
    const inputVisible = await mobilePage.isVisible('#domainInput');
    const btnVisible = await mobilePage.isVisible('#checkBtn');

    if (!inputVisible || !btnVisible) {
      await mobilePage.screenshot({ path: 'error_screenshot.png', fullPage: true });
      throw new Error('Lỗi Mobile Responsive: Nút bấm hoặc ô nhập bị ẩn trên điện thoại!');
    }

    console.log('🎉 TẤT CẢ BÀI TEST ĐÃ VƯỢT QUA HOÀN HẢO!');
  } catch (err) {
    console.error(`❌ PHÁT HIỆN LỖI: ${err.message}`);
    process.exit(1);
  } finally {
    await browser.close();
  }
})();