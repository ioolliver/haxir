use chromiumoxide::Page;
use std::fs;

fn evaluate_content(page: Page, content: String) {
    async_std::task::spawn(async move {
        page.wait_for_navigation_response().await.unwrap();
        page.evaluate(r#"window.exports = {}"#).await.unwrap();
        page.evaluate(content).await.unwrap();
    });
}

pub fn open(page: Page, path: String) -> async_std::task::JoinHandle<()> {
    async_std::task::spawn(async move {
        match fs::read_to_string(path) {
            Ok(content) => evaluate_content(page, content),
            Err(e) => println!("{e:?}"),
        }
    })
}
