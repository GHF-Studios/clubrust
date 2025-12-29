mod admin;
mod db;
mod web;

#[tokio::main]
async fn main() {
    db::init_db().expect("DB init failed");

    // Run admin + web server concurrently
    tokio::join!(
        admin::run_admin_socket(),
        web::start_web_server(),
    );
}
