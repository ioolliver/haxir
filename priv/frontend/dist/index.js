"use strict";
var __awaiter = (this && this.__awaiter) || function (thisArg, _arguments, P, generator) {
    function adopt(value) { return value instanceof P ? value : new P(function (resolve) { resolve(value); }); }
    return new (P || (P = Promise))(function (resolve, reject) {
        function fulfilled(value) { try { step(generator.next(value)); } catch (e) { reject(e); } }
        function rejected(value) { try { step(generator["throw"](value)); } catch (e) { reject(e); } }
        function step(result) { result.done ? resolve(result.value) : adopt(result.value).then(fulfilled, rejected); }
        step((generator = generator.apply(thisArg, _arguments || [])).next());
    });
};
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const puppeteer_1 = require("puppeteer");
const fs_1 = require("fs");
const path_1 = __importDefault(require("path"));
function startBrowser() {
    return __awaiter(this, void 0, void 0, function* () {
        let browser = yield (0, puppeteer_1.launch)({
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
    });
}
function getFirstPage(browser) {
    return __awaiter(this, void 0, void 0, function* () {
        let page;
        let pages = yield browser.pages();
        if (pages.length > 0)
            page = pages[0];
        else
            page = yield browser.newPage();
        return page;
    });
}
function managePage(browser) {
    return __awaiter(this, void 0, void 0, function* () {
        let page = yield getFirstPage(browser);
        yield page.goto("https://www.haxball.com/headless");
        return page;
    });
}
function startBot(page) {
    return __awaiter(this, void 0, void 0, function* () {
        yield page.evaluate(() => {
            window.exports = {};
        });
        (0, fs_1.readFile)(path_1.default.join(__dirname, "/bot.js"), "utf-8", (err, data) => {
            if (err)
                return console.log("ERROR: ", err);
            page.evaluate(data);
        });
    });
}
function main() {
    return __awaiter(this, void 0, void 0, function* () {
        let browser = yield startBrowser();
        let page = yield managePage(browser);
        yield startBot(page);
    });
}
main();
