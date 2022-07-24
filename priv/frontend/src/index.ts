import { Browser, launch, Page } from "puppeteer";
import { readFile } from "fs";
import path from "path";

async function startBrowser(): Promise<Browser> {
  let browser = await launch({
    headless: true,
    args: [
      "--autoplay-policy=user-gesture-required",
      "--disable-background-networking",
      "--disable-background-timer-throttling",
      "--disable-backgrounding-occluded-windows",
      "--disable-breakpad",
      "--disable-client-side-phishing-detection",
      "--disable-component-update",
      "--disable-default-apps",
      "--disable-dev-shm-usage",
      "--disable-domain-reliability",
      "--disable-extensions",
      "--disable-features=AudioServiceOutOfProcess",
      "--disable-hang-monitor",
      "--disable-ipc-flooding-protection",
      "--disable-notifications",
      "--disable-offer-store-unmasked-wallet-cards",
      "--disable-popup-blocking",
      "--disable-print-preview",
      "--disable-prompt-on-repost",
      "--disable-renderer-backgrounding",
      "--disable-setuid-sandbox",
      "--disable-speech-api",
      "--disable-sync",
      "--hide-scrollbars",
      "--ignore-gpu-blacklist",
      "--metrics-recording-only",
      "--mute-audio",
      "--no-default-browser-check",
      "--no-first-run",
      "--no-pings",
      "--no-sandbox",
      "--no-zygote",
      "--password-store=basic",
      "--use-gl=swiftshader",
      "--use-mock-keychain",
    ],
  });

  return browser;
}

async function getFirstPage(browser: Browser): Promise<Page> {
  let page: Page;
  let pages = await browser.pages();

  if (pages.length > 0) page = pages[0];
  else page = await browser.newPage();

  return page;
}

async function managePage(browser: Browser): Promise<Page> {
  let page = await getFirstPage(browser);

  await page.goto("https://www.haxball.com/headless");

  return page;
}

async function startBot(page: Page) {
  await page.evaluate(() => {
    window.exports = {};
  });

  readFile(path.join(__dirname, "/bot.js"), "utf-8", (err, data) => {
    if (err) return console.log("ERROR: ", err);

    page.evaluate(data);
  });
}

async function main() {
  let browser = await startBrowser();
  let page = await managePage(browser);

  await startBot(page);
}

main();
