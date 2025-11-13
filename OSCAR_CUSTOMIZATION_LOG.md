# OSCAR EMR Customization Log

**Purpose:** Build custom OSCAR WAR with embedded NextScript integrations (RingCentral, Ocean, Labs)

**Date Started:** 2025-11-13

## Current Architecture (Before Custom Build)

- **OSCAR:** Standard WAR from SourceForge (unmodified)
- **Integrations:** Separate Python Flask microservice (port 8080)
- **Setup Wizard:** Separate React app (port 8568)
- **Problem:** Integrations not embedded in OSCAR UI - separate services

## Target Architecture (After Custom Build)

- **OSCAR:** Custom WAR with integration UI elements
- **Integrations:** Same Python microservice BUT accessible from OSCAR UI
- **Setup Wizard:** Same (used for initial config only)
- **Goal:** Doctors use OSCAR UI to send fax/SMS, create Ocean referrals

## Files to Modify in OSCAR Source

### 1. Admin Menu (`src/main/webapp/admin/admin.jsp`)
**Add:** "Integrations" menu item linking to integration management

### 2. Demographic Page (`src/main/webapp/demographic/demographiccontrol.jsp`)
**Add:** "Send Fax" and "Send SMS" buttons in patient actions

### 3. New Integration Management Page (`src/main/webapp/admin/integrations.jsp`)
**Create:** UI to manage RingCentral, Ocean, Labs settings (calls setup wizard API)

### 4. Integration Action Pages (already created in deployment/oscar/webapp/integrations/)
- `sendFax.jsp` - Send fax form + API call
- `sendSMS.jsp` - Send SMS form + API call
- These will be copied into custom WAR during build

## Build Process

1. Clone OSCAR source
2. Create branch: `nextscript-integration`
3. Make modifications (tracked in git)
4. Build: `mvn clean package -DskipTests`
5. Output: `target/oscar-NEXTSCRIPT.war`
6. Upload to GitHub releases
7. Update Dockerfile to download from GitHub instead of SourceForge

## Verification Steps

- [ ] Custom WAR size > standard WAR (additional files)
- [ ] Extract WAR and verify integration JSP files present
- [ ] SHA256 checksum differs from standard OSCAR
- [ ] Git log shows all modifications
- [ ] OSCAR UI shows "Integrations" menu item
- [ ] "Send Fax" button appears on demographic page

## Progress Tracking

See TODO list in code session or run:
```bash
git log --oneline --grep="OSCAR customization"
```

## Changes Made (Session 2025-11-13)

### ✅ 1. Admin Menu Integration (COMPLETED)
**File:** `src/main/webapp/admin/admin.jsp`
**Line:** ~987-999
**Change:** Added "NextScript Integrations" admin box with links to:
- Manage Integrations (opens integrations.jsp popup)
- Setup Wizard (opens http://hostname:8568)

### ✅ 2. Integration Management Page (COMPLETED)
**File:** `src/main/webapp/admin/integrations.jsp` (NEW - 166 lines)
**Purpose:** Central UI to manage all NextScript integrations
**Features:**
- Status indicators for RingCentral, Ocean, Labs
- Configure buttons → opens setup wizard at specific step
- Test connection buttons → AJAX calls to integration API
- Service health check → verifies integration service is running
- Clean UI with color-coded status (green=active, red=inactive)

### ✅ 3. Integration Bridge Files (COMPLETED)
**Directory:** `src/main/webapp/integrations/` (COPIED from deployment)
**Files:**
- `sendFax.jsp` (70 lines) - Fax form with API call to integrations:8080
- `sendSMS.jsp` (65 lines) - SMS form with API call to integrations:8080
- `README.md` - Usage documentation

### ⏸️ 4. Demographic Page Buttons (DEFERRED)
**Reason:** OSCAR's demographic UI architecture is complex with multiple pages
**Alternative:** Access integrations via:
1. Admin menu → NextScript Integrations → Manage Integrations
2. Direct URL: `/admin/integrations.jsp`
3. Integration pages: `/integrations/sendFax.jsp`, `/integrations/sendSMS.jsp`

## Rollback Plan

If custom build fails:
1. Revert Dockerfile line 34 to SourceForge URL
2. Remove custom WAR from GitHub releases
3. Rebuild with standard OSCAR

## Context Rebuild Instructions

If this session runs out of context:
1. Read this file first
2. Check `git log oscar-source/` for completed modifications
3. Check todo list state
4. Continue from last pending todo
