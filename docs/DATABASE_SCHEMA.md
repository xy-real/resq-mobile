# Database Schema Documentation

## Overview
This document describes the database schema for the ResQ Disaster Response System.

## Tables

### 1. STUDENTS
Primary user directory containing all registered students.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| student_id | TEXT | PRIMARY KEY | Unique student identifier |
| name | TEXT | NOT NULL | Student's full name |
| contact_number | TEXT | | Phone number for SMS fallback |
| home_lat | DECIMAL(10,8) | | Home location latitude |
| home_lng | DECIMAL(11,8) | | Home location longitude |
| registered_home_risk_label | TEXT | | Risk assessment of home area |
| last_known_lat | DECIMAL(10,8) | | Most recent GPS latitude |
| last_known_lng | DECIMAL(11,8) | | Most recent GPS longitude |
| last_status | TEXT | DEFAULT 'UNKNOWN' | Current status enum |
| last_update_timestamp | TIMESTAMPTZ | | When status was last updated |
| last_update_source | TEXT | | Source of last update (APP/SMS) |

**Status Enum Values:** SAFE, NEEDS_ASSISTANCE, CRITICAL, EVACUATED, UNKNOWN

---

### 2. STATUS_LOGS
Append-only ledger of all status updates from students.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | UUID | PRIMARY KEY | Auto-generated log ID |
| student_id | TEXT | FOREIGN KEY | References students(student_id) |
| status | TEXT | NOT NULL | Status at time of log |
| timestamp | TIMESTAMPTZ | DEFAULT NOW() | When update was received |
| source | TEXT | NOT NULL | Update source (APP/SMS) |
| validation_flag | BOOLEAN | DEFAULT TRUE | FALSE for malformed SMS |

**Purpose:** Complete audit trail for status changes and analytics.

---

### 3. EVACUATION_CENTERS
Locations of designated evacuation sites.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | UUID | PRIMARY KEY | Auto-generated center ID |
| center_name | TEXT | NOT NULL | Name of evacuation center |
| latitude | DECIMAL(10,8) | NOT NULL | Center GPS latitude |
| longitude | DECIMAL(11,8) | NOT NULL | Center GPS longitude |

---

### 4. SYSTEM_SETTINGS
Global configuration for disaster mode (single-row table).

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | INTEGER | PRIMARY KEY DEFAULT 1 | Always 1 (singleton) |
| is_disaster_mode_active | BOOLEAN | DEFAULT FALSE | Master disaster mode switch |
| mode_activated_at | TIMESTAMPTZ | | When disaster mode was enabled |

**Constraint:** CHECK to ensure only one row exists (id = 1).

---

### 5. ADMINS
Authorized admin users for dashboard access.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | UUID | PRIMARY KEY | Auto-generated admin ID |
| email | TEXT | UNIQUE, NOT NULL | Admin email for authentication |
| role | TEXT | NOT NULL | Admin role level |

**Role Enum Values:** SUPER_ADMIN, VIEWER

---

## Relationships

```
STUDENTS (1) ---> (many) STATUS_LOGS
```

## Indexes

- `idx_status_logs_student_id` on STATUS_LOGS(student_id)
- `idx_status_logs_timestamp` on STATUS_LOGS(timestamp DESC)
- `idx_students_last_status` on STUDENTS(last_status)
- `idx_students_last_update` on STUDENTS(last_update_timestamp DESC)

## Auto-Triage Logic

Students are automatically marked as UNKNOWN if:
- Disaster mode is active
- No update received within 6 hours of `mode_activated_at` or their `last_update_timestamp`
