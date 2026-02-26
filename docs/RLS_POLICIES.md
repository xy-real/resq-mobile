# Row-Level Security (RLS) Policies

## Overview
This document outlines the security policies for each table in the ResQ system.

---

## 1. STUDENTS Table

### Mobile App Policies

**Policy Name:** `students_select_own`
- **Operation:** SELECT
- **For:** authenticated users
- **Condition:** `auth.uid()::text = student_id`
- **Purpose:** Students can only view their own record

**Policy Name:** `students_update_own_status`
- **Operation:** UPDATE
- **For:** authenticated users
- **Condition:** `auth.uid()::text = student_id`
- **Columns:** `last_known_lat`, `last_known_lng`, `last_status`, `last_update_timestamp`, `last_update_source`
- **Purpose:** Students can update their status and location only

### Admin Policies

**Policy Name:** `admins_select_all_students`
- **Operation:** SELECT
- **For:** authenticated users
- **Condition:** `EXISTS (SELECT 1 FROM admins WHERE email = auth.jwt()->>'email')`
- **Purpose:** Admins can view all student records

**Policy Name:** `admins_update_all_students`
- **Operation:** UPDATE
- **For:** authenticated users
- **Condition:** `EXISTS (SELECT 1 FROM admins WHERE email = auth.jwt()->>'email' AND role = 'SUPER_ADMIN')`
- **Purpose:** Super admins can manually override student data

---

## 2. STATUS_LOGS Table

### Mobile App Policies

**Policy Name:** `students_insert_own_logs`
- **Operation:** INSERT
- **For:** authenticated users
- **Condition:** `auth.uid()::text = student_id`
- **Purpose:** Students can create log entries for themselves

**Policy Name:** `students_select_own_logs`
- **Operation:** SELECT
- **For:** authenticated users
- **Condition:** `auth.uid()::text = student_id`
- **Purpose:** Students can view their own status history

### Admin Policies

**Policy Name:** `admins_select_all_logs`
- **Operation:** SELECT
- **For:** authenticated users
- **Condition:** `EXISTS (SELECT 1 FROM admins WHERE email = auth.jwt()->>'email')`
- **Purpose:** Admins can view all status logs for analytics

**Policy Name:** `admins_insert_logs`
- **Operation:** INSERT
- **For:** authenticated users
- **Condition:** `EXISTS (SELECT 1 FROM admins WHERE email = auth.jwt()->>'email' AND role = 'SUPER_ADMIN')`
- **Purpose:** Super admins can insert logs (manual overrides, SMS gateway)

---

## 3. EVACUATION_CENTERS Table

**Policy Name:** `public_select_centers`
- **Operation:** SELECT
- **For:** authenticated users
- **Condition:** `true`
- **Purpose:** All authenticated users can view evacuation centers

**Policy Name:** `admins_manage_centers`
- **Operation:** INSERT, UPDATE, DELETE
- **For:** authenticated users
- **Condition:** `EXISTS (SELECT 1 FROM admins WHERE email = auth.jwt()->>'email' AND role = 'SUPER_ADMIN')`
- **Purpose:** Only super admins can manage evacuation centers

---

## 4. SYSTEM_SETTINGS Table

**Policy Name:** `public_select_settings`
- **Operation:** SELECT
- **For:** authenticated users
- **Condition:** `true`
- **Purpose:** All users need to know if disaster mode is active

**Policy Name:** `admins_update_settings`
- **Operation:** UPDATE
- **For:** authenticated users
- **Condition:** `EXISTS (SELECT 1 FROM admins WHERE email = auth.jwt()->>'email' AND role = 'SUPER_ADMIN')`
- **Purpose:** Only super admins can toggle disaster mode

---

## 5. ADMINS Table

**Policy Name:** `admins_select_own`
- **Operation:** SELECT
- **For:** authenticated users
- **Condition:** `email = auth.jwt()->>'email'`
- **Purpose:** Admins can view their own record

**Policy Name:** `super_admins_manage_admins`
- **Operation:** INSERT, UPDATE, DELETE
- **For:** authenticated users
- **Condition:** `EXISTS (SELECT 1 FROM admins WHERE email = auth.jwt()->>'email' AND role = 'SUPER_ADMIN')`
- **Purpose:** Only super admins can manage other admins

---

## Privacy Notes

- **Location Data:** Students can only see their own coordinates. Admins with proper role can access all locations.
- **SMS Source:** The SMS gateway uses a service role key (bypasses RLS) to insert logs with `validation_flag = false` for invalid messages.
- **Disaster Mode:** Read-only for students, write access for super admins only.
