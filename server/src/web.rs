use axum::{
    extract::Form,
    response::Html,
    routing::{get, post},
    Router,
};
use chrono::Utc;
use rusqlite::params;
use serde::Deserialize;
use std::{
    hash::{DefaultHasher, Hash, Hasher},
    net::SocketAddr
};

use crate::db::get_db_conn;

#[derive(Deserialize)]
struct LoginForm {
    username: String,
    password: String,
}

#[derive(Deserialize)]
struct RegisterForm {
    username: String,
    password: String,
}

pub async fn start_web_server() {
    let app = Router::new()
        .route("/", get(homepage))
        .route("/api/login", get(login_form).post(handle_login))
        .route("/api/register", get(register_form).post(handle_register));

    let addr: SocketAddr = "[::]:8080".parse().unwrap();
    println!("🌐 Web server running at http://{}/", addr);

    let listener = tokio::net::TcpListener::bind(addr).await.unwrap();
    axum::serve(listener, app).await.unwrap();
}

async fn homepage() -> Html<&'static str> {
    Html(r#"
        <h1>🏡 Welcome to ClubRust</h1>
        <p><a href='/api/login'>Login</a> | <a href='/api/register'>Register</a></p>
    "#)
}

async fn login_form() -> Html<&'static str> {
    Html(r#"
        <h2>Login</h2>
        <form method="post">
            Username: <input name="username"><br>
            Password: <input type="password" name="password"><br>
            <button type="submit">Login</button>
        </form>
    "#)
}

async fn register_form() -> Html<&'static str> {
    Html(r#"
        <h2>Register</h2>
        <form method="post">
            Username: <input name="username"><br>
            Password: <input type="password" name="password"><br>
            <button type="submit">Register</button>
        </form>
    "#)
}

async fn handle_login(Form(data): Form<LoginForm>) -> Html<String> {
    Html(format!("🔐 Login attempt: {} / {}", data.username, data.password))
}

async fn handle_register(Form(data): Form<RegisterForm>) -> Html<String> {
    let conn = match get_db_conn() {
        Ok(c) => c,
        Err(e) => return Html(format!("❌ DB error: {}", e)),
    };

    let now = Utc::now().to_rfc3339();

    let mut password_hasher = DefaultHasher::new();
    data.password.hash(&mut password_hasher);
    let password_hash = password_hasher.finish().to_string();

    let result = conn.execute(
        "INSERT INTO accounts (username, password_hash, created_at) VALUES (?1, ?2, ?3)",
        params![data.username, password_hash, now],
    );

    match result {
        Ok(_) => Html("✅ Account registered!".into()),
        Err(e) => Html(format!("❌ Failed to register: {}", e)),
    }
}
