mod haxball;

use chromiumoxide::browser::{Browser, BrowserConfig};
use futures::StreamExt;

#[rustler::nif]
fn run(path: String) {
    async_std::task::spawn(async move {
        let (browser, mut handler) = Browser::launch(
            BrowserConfig::builder()
                .args([
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
                ])
                .build()
                .unwrap(),
        )
        .await
        .unwrap();

        let handle = async_std::task::spawn(async move {
            loop {
                let _ = handler.next().await.unwrap();
            }
        });

        let page = browser
            .new_page("http://www.haxball.com/headless")
            .await
            .unwrap();

        haxball::open(page, path).await;

        handle.await;
    });
}

rustler::init!("Elixir.Haxir.Native", [run]);
