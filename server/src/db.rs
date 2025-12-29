use std::path::Path;
use rusqlite::{Connection, Result};

pub(super) fn init_db() -> Result<()> {
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

pub fn get_db_conn() -> Result<Connection, rusqlite::Error> {
    Connection::open("/home/clubrust/data/clubrust.db")
}
