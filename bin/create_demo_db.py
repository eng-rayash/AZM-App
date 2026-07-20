"""
مُدير — Demo SQLite Database Generator
======================================
يُنشئ قاعدة بيانات تجريبية واقعية لتطبيق "مُدير"
تبدو كأنها مستخدمة منذ 4 أشهر
لا تحتوي على أي بيانات حقيقية
"""

import sqlite3
import uuid
import time
import datetime
import json
import hashlib
import random
import os

OUTPUT_PATH = r"assets\mudiri_demo.sqlite"
NOW = datetime.datetime(2026, 6, 27, 20, 30, 0)

def ms(dt: datetime.datetime) -> int:
    return int(dt.timestamp() * 1000)

def ago(days=0, hours=0) -> datetime.datetime:
    return NOW - datetime.timedelta(days=days, hours=hours)

def future(days=0, hours=0) -> datetime.datetime:
    return NOW + datetime.timedelta(days=days, hours=hours)

def uid() -> str:
    return str(uuid.uuid4())

def date_str(dt: datetime.datetime) -> str:
    return dt.strftime("%Y-%m-%d")

def time_str(dt: datetime.datetime) -> str:
    return dt.strftime("%H:%M")

def pin_hash(pin: str) -> str:
    return hashlib.sha256(pin.encode()).hexdigest()

def create_database():
    os.makedirs(os.path.dirname(OUTPUT_PATH), exist_ok=True)
    if os.path.exists(OUTPUT_PATH):
        os.remove(OUTPUT_PATH)
    
    conn = sqlite3.connect(OUTPUT_PATH)
    cur = conn.cursor()
    cur.execute("PRAGMA foreign_keys = ON")
    cur.execute("PRAGMA journal_mode = WAL")
    cur.execute("PRAGMA user_version = 5")

    cur.executescript("""
    CREATE TABLE IF NOT EXISTS users (
        id INTEGER PRIMARY KEY AUTOINCREMENT, sync_id TEXT NOT NULL, created_at INTEGER NOT NULL, updated_at INTEGER NOT NULL, is_deleted INTEGER NOT NULL DEFAULT 0, created_by TEXT,
        display_name TEXT NOT NULL, pin_hash TEXT, auth_method INTEGER NOT NULL DEFAULT 0, is_biometric_enabled INTEGER NOT NULL DEFAULT 0, role INTEGER NOT NULL DEFAULT 0, avatar_path TEXT
    );
    CREATE TABLE IF NOT EXISTS meetings (
        id INTEGER PRIMARY KEY AUTOINCREMENT, sync_id TEXT NOT NULL, created_at INTEGER NOT NULL, updated_at INTEGER NOT NULL, is_deleted INTEGER NOT NULL DEFAULT 0, created_by TEXT,
        title TEXT NOT NULL, meeting_type INTEGER NOT NULL DEFAULT 0, date TEXT NOT NULL, time TEXT NOT NULL, end_time TEXT, location TEXT, objective TEXT, agenda TEXT, decisions TEXT, outcomes TEXT, attendees TEXT, attachments TEXT, status INTEGER NOT NULL DEFAULT 0, priority INTEGER NOT NULL DEFAULT 2, notes TEXT, minutes TEXT, recurrence_rule TEXT, custom_meeting_type TEXT
    );
    CREATE TABLE IF NOT EXISTS tasks (
        id INTEGER PRIMARY KEY AUTOINCREMENT, sync_id TEXT NOT NULL, created_at INTEGER NOT NULL, updated_at INTEGER NOT NULL, is_deleted INTEGER NOT NULL DEFAULT 0, created_by TEXT,
        title TEXT NOT NULL, description TEXT, due_date TEXT, assigned_to TEXT, priority INTEGER NOT NULL DEFAULT 2, status INTEGER NOT NULL DEFAULT 0, linked_meeting_id INTEGER
    );
    CREATE TABLE IF NOT EXISTS follow_ups (
        id INTEGER PRIMARY KEY AUTOINCREMENT, sync_id TEXT NOT NULL, created_at INTEGER NOT NULL, updated_at INTEGER NOT NULL, is_deleted INTEGER NOT NULL DEFAULT 0, created_by TEXT,
        title TEXT NOT NULL, notes TEXT, target_date TEXT, entity_type INTEGER NOT NULL DEFAULT 0, entity_id INTEGER, priority INTEGER NOT NULL DEFAULT 2, status INTEGER NOT NULL DEFAULT 0, assigned_to TEXT
    );
    CREATE TABLE IF NOT EXISTS directives (
        id INTEGER PRIMARY KEY AUTOINCREMENT, sync_id TEXT NOT NULL, created_at INTEGER NOT NULL, updated_at INTEGER NOT NULL, is_deleted INTEGER NOT NULL DEFAULT 0, created_by TEXT,
        title TEXT NOT NULL, details TEXT, source TEXT, assigned_to TEXT, deadline TEXT, priority INTEGER NOT NULL DEFAULT 1, status INTEGER NOT NULL DEFAULT 0
    );
    CREATE TABLE IF NOT EXISTS contacts (
        id INTEGER PRIMARY KEY AUTOINCREMENT, sync_id TEXT NOT NULL, created_at INTEGER NOT NULL, updated_at INTEGER NOT NULL, is_deleted INTEGER NOT NULL DEFAULT 0, created_by TEXT,
        name TEXT NOT NULL, position TEXT, company TEXT, phone_number TEXT, email TEXT, is_vip INTEGER NOT NULL DEFAULT 0, notes TEXT
    );
    CREATE TABLE IF NOT EXISTS appointments (
        id INTEGER PRIMARY KEY AUTOINCREMENT, sync_id TEXT NOT NULL, created_at INTEGER NOT NULL, updated_at INTEGER NOT NULL, is_deleted INTEGER NOT NULL DEFAULT 0, created_by TEXT,
        title TEXT NOT NULL, contact_id INTEGER, date TEXT NOT NULL, time TEXT NOT NULL, duration_minutes INTEGER NOT NULL DEFAULT 30, location TEXT, status INTEGER NOT NULL DEFAULT 0
    );
    CREATE TABLE IF NOT EXISTS archive (
        id INTEGER PRIMARY KEY AUTOINCREMENT, sync_id TEXT NOT NULL, created_at INTEGER NOT NULL, updated_at INTEGER NOT NULL, is_deleted INTEGER NOT NULL DEFAULT 0, created_by TEXT,
        title TEXT NOT NULL, reference_number TEXT, hijri_date TEXT, document_date TEXT, directed_entity TEXT, category TEXT, local_file_path TEXT, tags TEXT, notes TEXT, is_confidential INTEGER NOT NULL DEFAULT 0
    );
    CREATE TABLE IF NOT EXISTS security_logs (
        id INTEGER PRIMARY KEY AUTOINCREMENT, sync_id TEXT NOT NULL, created_at INTEGER NOT NULL, updated_at INTEGER NOT NULL, is_deleted INTEGER NOT NULL DEFAULT 0, created_by TEXT,
        action INTEGER NOT NULL, details TEXT, device_info TEXT, ip_address TEXT
    );
    CREATE TABLE IF NOT EXISTS app_settings (
        id INTEGER PRIMARY KEY AUTOINCREMENT, sync_id TEXT NOT NULL, created_at INTEGER NOT NULL, updated_at INTEGER NOT NULL, is_deleted INTEGER NOT NULL DEFAULT 0, created_by TEXT,
        key TEXT NOT NULL UNIQUE, value TEXT NOT NULL, category TEXT
    );
    CREATE TABLE IF NOT EXISTS calls (
        id INTEGER PRIMARY KEY AUTOINCREMENT, sync_id TEXT NOT NULL, created_at INTEGER NOT NULL, updated_at INTEGER NOT NULL, is_deleted INTEGER NOT NULL DEFAULT 0, created_by TEXT,
        caller_name TEXT NOT NULL, phone_number TEXT, call_type INTEGER NOT NULL DEFAULT 0, date TEXT NOT NULL, time TEXT NOT NULL, summary TEXT, is_important INTEGER NOT NULL DEFAULT 0
    );
    CREATE TABLE IF NOT EXISTS visitors (
        id INTEGER PRIMARY KEY AUTOINCREMENT, sync_id TEXT NOT NULL, created_at INTEGER NOT NULL, updated_at INTEGER NOT NULL, is_deleted INTEGER NOT NULL DEFAULT 0, created_by TEXT,
        visitor_name TEXT NOT NULL, company TEXT, purpose TEXT, appointment_id TEXT, entry_time TEXT, exit_time TEXT, status INTEGER NOT NULL DEFAULT 0
    );
    CREATE TABLE IF NOT EXISTS notes (
        id INTEGER PRIMARY KEY AUTOINCREMENT, sync_id TEXT NOT NULL, created_at INTEGER NOT NULL, updated_at INTEGER NOT NULL, is_deleted INTEGER NOT NULL DEFAULT 0, created_by TEXT,
        title TEXT, content TEXT NOT NULL, color_code TEXT, tags TEXT
    );
    CREATE TABLE IF NOT EXISTS movements (
        id INTEGER PRIMARY KEY AUTOINCREMENT, sync_id TEXT NOT NULL, created_at INTEGER NOT NULL, updated_at INTEGER NOT NULL, is_deleted INTEGER NOT NULL DEFAULT 0, created_by TEXT,
        destination TEXT NOT NULL, purpose TEXT, date TEXT NOT NULL, time TEXT NOT NULL, type INTEGER NOT NULL DEFAULT 0, notes TEXT
    );
    CREATE TABLE IF NOT EXISTS routine_tasks (
        id INTEGER PRIMARY KEY AUTOINCREMENT, sync_id TEXT NOT NULL, created_at INTEGER NOT NULL, updated_at INTEGER NOT NULL, is_deleted INTEGER NOT NULL DEFAULT 0, created_by TEXT,
        title TEXT NOT NULL, description TEXT, category TEXT NOT NULL DEFAULT 'personal', priority INTEGER NOT NULL DEFAULT 2, repeat TEXT NOT NULL DEFAULT 'daily', time TEXT, days_of_week TEXT NOT NULL DEFAULT '[]', is_active INTEGER NOT NULL DEFAULT 1
    );
    CREATE TABLE IF NOT EXISTS routine_completions (
        id INTEGER PRIMARY KEY AUTOINCREMENT, sync_id TEXT NOT NULL, created_at INTEGER NOT NULL, updated_at INTEGER NOT NULL, is_deleted INTEGER NOT NULL DEFAULT 0, created_by TEXT,
        routine_task_sync_id TEXT NOT NULL, date_key TEXT NOT NULL
    );
    """)

    created = ms(ago(days=120))
    cur.execute("INSERT INTO users VALUES (1, ?, ?, ?, 0, NULL, 'م. خالد العتيبي', ?, 1, 1, 0, NULL)", (uid(), created, created, pin_hash("1234")))
    
    conn.commit()
    conn.close()
    print("Demo database script created successfully.")

if __name__ == "__main__":
    create_database()
