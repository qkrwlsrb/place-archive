const { chromium } = require("playwright");
(async () => {
  const browser = await chromium.launch({ headless: true });
  const page = await browser.newPage();
  const filePath = "file:///C:/project/place_archive/docs/index.html";
  await page.goto(filePath, { waitUntil: "networkidle" });

  // 슬라이드 11로 이동 (11번째 dot 클릭)
  const dots = await page.locator(".dot").all();
  console.log("총 dot 수:", dots.length);
  await dots[10].click();  // 0-indexed → 11번 슬라이드
  await page.waitForTimeout(800);

  // 슬라이드 11 HTML 확인
  const s11 = await page.locator(".s11").first();
  const visible = await s11.isVisible();
  console.log("s11 visible:", visible);

  // video 태그 존재 확인
  const video = await page.locator(".s11 video");
  const videoCount = await video.count();
  console.log("video 개수:", videoCount);

  // video src 확인
  if (videoCount > 0) {
    const src = await video.locator("source").getAttribute("src");
    console.log("video src:", src);
  }

  // 스크린샷
  await page.screenshot({ path: "C:/project/place_archive/docs/slide11_check.png", fullPage: false });
  console.log("스크린샷 저장 완료");

  await browser.close();
})();
