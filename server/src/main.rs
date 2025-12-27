use tokio::net::UnixListener;
use tokio::io::{AsyncBufReadExt, AsyncWriteExt, BufReader};
use std::path::Path;
use std::fs;
use std::os::unix::fs::PermissionsExt;

#[tokio::main]
async fn main() {
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
