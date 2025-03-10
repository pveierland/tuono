use crate::config::GLOBAL_CONFIG;
use crate::manifest::load_manifest;
use crate::mode::{Mode, GLOBAL_MODE};
use axum::routing::{get, Router};
use colored::Colorize;
use ssr_rs::Ssr;
use tower_http::compression::CompressionLayer;
use tower_http::services::ServeDir;
use tuono_internal::config::Config;

use crate::{
    catch_all::catch_all, logger::LoggerLayer, vite_reverse_proxy::vite_reverse_proxy,
    vite_websocket_proxy::vite_websocket_proxy,
};

const DEV_PUBLIC_DIR: &str = "public";
const PROD_PUBLIC_DIR: &str = "out/client";

pub fn tuono_internal_init_v8_platform() {
    Ssr::create_platform();
}

#[derive(Debug)]
pub struct Server {
    router: Router,
    mode: Mode,
    pub listener: tokio::net::TcpListener,
    pub address: String,
    pub base_url: String,
}

impl Server {
    pub async fn init(router: Router, mode: Mode) -> Server {
        let config = Config::get().expect("[SERVER] Failed to load config");

        let _ = GLOBAL_MODE.set(mode);
        let _ = GLOBAL_CONFIG.set(config.clone());

        if mode == Mode::Prod {
            load_manifest()
        }

        let server_address = format!("{}:{}", config.server.host, config.server.port);

        let server_base_url = match &config.server.origin {
            Some(origin) => origin.clone(),
            None => format!("http://{}", server_address),
        };

        Server {
            router,
            mode,
            address: server_address.clone(),
            base_url: server_base_url,
            listener: tokio::net::TcpListener::bind(&server_address)
                .await
                .expect("[SERVER] Failed to bind to address"),
        }
    }

    pub async fn start(self) {
        /*
         * Format the server address as a valid URL so that it becomes clickable in the CLI
         * @see https://github.com/tuono-labs/tuono/issues/460
         */

        if self.mode == Mode::Dev {
            println!("  Ready at: {}\n", self.base_url.blue().bold());
            let router = self
                .router
                .to_owned()
                .layer(LoggerLayer::new())
                .route("/vite-server/", get(vite_websocket_proxy))
                .route("/vite-server/*path", get(vite_reverse_proxy))
                .fallback_service(
                    ServeDir::new(DEV_PUBLIC_DIR)
                        .fallback(get(catch_all).layer(LoggerLayer::new())),
                );

            axum::serve(self.listener, router)
                .await
                .expect("Failed to serve development server");
        } else {
            println!(
                "  Production server at: {}\n",
                self.base_url.blue().bold()
            );

            let compression_layer: CompressionLayer = CompressionLayer::new()
                .br(true)
                .deflate(true)
                .gzip(true)
                .zstd(true);

            let router = self
                .router
                .to_owned()
                .layer(LoggerLayer::new())
                .layer(compression_layer)
                .fallback_service(
                    ServeDir::new(PROD_PUBLIC_DIR)
                        .fallback(get(catch_all).layer(LoggerLayer::new())),
                );

            axum::serve(self.listener, router)
                .await
                .expect("Failed to serve production server");
        }
    }
}
