use tokio::net::UnixListener;
use tokio::io::{AsyncBufReadExt, AsyncWriteExt, BufReader};
use std::path::Path;
use std::fs;
use std::os::unix::fs::PermissionsExt;
use rusqlite::{Connection, Result};

fn init_db() -> Result<()> {
    let db_path = "/home/clubrust/data/clubrust.db";

    let first_time = !Path::new(db_path).exists();
    let conn = Connection::open(db_path)?;

    if first_time {
        println!("📁 Running DB init script...");
        let init_sql = std::fs::read_to_string("/home/clubrust/data/init.sql")
            .map_err(|e| rusqlite::Error::FromSqlConversionFailure(0, rusqlite::types::Type::Text, Box::new(e)))?;
        conn.execute_batch(&init_sql)?;
    }

    println!("🗄️  Database ready at {}", db_path);
    Ok(())
}

#[tokio::main]
async fn main() {
    init_db().expect("DB init failed");

    // Clean up any stale socket
    let socket_path = "/run/clubrust/clubrust.sock";
    if Path::new(socket_path).exists() {
        fs::remove_file(socket_path).unwrap();
    }

    let listener = UnixListener::bind(socket_path).expect("Failed to bind socket");
    println!("🔌 Admin socket listening at {}", socket_path);

    fs::set_permissions(socket_path, fs::Permissions::from_mode(0o666)).unwrap();

    loop {
        let (stream, _) = listener.accept().await.expect("Socket accept failed");
        let (reader, mut writer) = stream.into_split();
        let mut lines = BufReader::new(reader).lines();

        while let Ok(Some(line)) = lines.next_line().await {
            let response = format!("Echo: {}\n", line);
            writer.write_all(response.as_bytes()).await.unwrap();
        }
    }
}
