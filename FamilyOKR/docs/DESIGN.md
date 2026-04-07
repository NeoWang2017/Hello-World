# Family OKR Tracker — Design Specification

## Overview

A family OKR (Objectives & Key Results) tracking system with:
- **Native app** (SwiftUI) for iOS and macOS
- **Lark bot** for updating progress via natural language in a family group chat
- **LLM agent** for parsing messages into structured OKR updates
- **iCloud (CloudKit)** as the single source of truth, synced across all devices
- **VPS server** (Node.js/TypeScript) hosting the Lark bot and LLM agent

---

## Architecture

```
┌──────────────────────────────────────────────────────┐
│                  Apple Ecosystem                      │
│                                                      │
│  ┌──────────┐ ┌──────────┐ ┌──────────┐             │
│  │ iPhone   │ │ iPhone   │ │ Mac      │  ...         │
│  │ (Mom)    │ │ (Jack)   │ │ (Dad)    │             │
│  └────┬─────┘ └────┬─────┘ └────┬─────┘             │
│       │             │            │                    │
│       └─────────────┼────────────┘                   │
│                     ▼                                │
│              ┌─────────────┐                         │
│              │   iCloud    │                         │
│              │  CloudKit   │                         │
│              │  Private DB │                         │
│              └──────┬──────┘                         │
└─────────────────────┼────────────────────────────────┘
                      │
                      │ CloudKit Server-to-Server API
                      │
┌─────────────────────┼────────────────────────────────┐
│   VPS               │                                │
│              ┌──────▼──────┐                         │
│              │  Node.js/TS │                         │
│              │  Server     │                         │
│              │             │                         │
│              │  ┌────────┐ │    ┌──────────────┐     │
│              │  │Lark Bot│ │    │  LLM Agent   │     │
│              │  │Webhook │─┼───►│  (Claude API │     │
│              │  │Handler │ │    │   compatible)│     │
│              │  └────────┘ │    └──────────────┘     │
│              └─────────────┘                         │
└──────────────────────────────────────────────────────┘
                      ▲
                      │ Webhook
               ┌──────┴───────┐
               │  Lark Group  │
               │  "Family OKR"│
               │              │
               │  Dad: I ran  │
               │    5km today │
               │              │
               │  Bot: Done!  │
               │  Running +5km│
               │  (89/200)    │
               └──────────────┘
```

---

## Data Model

### FamilyMember
| Field        | Type     | Notes                              |
|-------------|----------|-------------------------------------|
| id          | UUID     | Primary key                         |
| name        | String   | Display name                        |
| role        | Enum     | parent, child, member               |
| avatarEmoji | String   | Emoji avatar (e.g. "👨")            |
| colorHex    | String   | Profile color                       |
| larkUserId  | String?  | Lark open_id for bot message matching|
| createdAt   | Date     |                                     |

### Objective
| Field       | Type     | Notes                              |
|------------|----------|-------------------------------------|
| id         | UUID     | Primary key                         |
| title      | String   | e.g. "Healthier family lifestyle"   |
| description| String   | Optional detail                     |
| year       | Int      | OKR year (e.g. 2026)               |
| icon       | String   | SF Symbol name                      |
| priority   | Enum     | high, medium, low                   |
| ownerId    | UUID?    | FK → FamilyMember (null = shared)   |
| createdAt  | Date     |                                     |
| updatedAt  | Date     |                                     |

### KeyResult
| Field       | Type     | Notes                              |
|------------|----------|-------------------------------------|
| id         | UUID     | Primary key                         |
| objectiveId| UUID     | FK → Objective                      |
| title      | String   | e.g. "Run 200km"                    |
| targetValue| Double   | e.g. 200                            |
| currentValue| Double  | e.g. 89                             |
| unit       | String   | e.g. "km", "books", "times"         |
| assigneeId | UUID?    | FK → FamilyMember                   |
| createdAt  | Date     |                                     |
| updatedAt  | Date     |                                     |

### ProgressEntry
| Field       | Type     | Notes                              |
|------------|----------|-------------------------------------|
| id         | UUID     | Primary key                         |
| keyResultId| UUID     | FK → KeyResult                      |
| delta      | Double   | Change amount (e.g. +5)             |
| newValue   | Double   | Value after update                  |
| note       | String   | Optional note                       |
| source     | Enum     | "manual" (app) or "lark" (bot)      |
| rawMessage | String?  | Original Lark message (if from bot) |
| memberId   | UUID     | FK → FamilyMember who made update   |
| date       | Date     |                                     |

### ActivityLog
| Field       | Type     | Notes                              |
|------------|----------|-------------------------------------|
| id         | UUID     | Primary key                         |
| type       | Enum     | "progress", "created", "edited"     |
| summary    | String   | Human-readable description          |
| memberId   | UUID?    | Who triggered it                    |
| objectiveId| UUID?    | Related objective                   |
| keyResultId| UUID?    | Related key result                  |
| source     | Enum     | "manual" or "lark"                  |
| date       | Date     |                                     |

---

## SwiftUI App

### Tech Stack
- SwiftUI (iOS 17+, macOS 14+)
- SwiftData + CloudKit (automatic iCloud sync)

### Navigation

**macOS:** NavigationSplitView with sidebar
**iOS/iPad:** TabView

### Screens

#### 1. Dashboard
- Year progress bar (days elapsed / 365)
- Overall OKR progress ring
- Per-member progress summary cards
- Recent activity feed (last 10 updates, shows source icon for lark/manual)
- Quick stats: total objectives, completed, at risk

#### 2. Objectives List
- Grouped by: All / Per Member
- Each row: title, progress ring, owner avatar, status badge, priority
- Filter: by member, by status
- Search by title
- Tap → Objective Detail
- Add button → create new objective (app only)

#### 3. Objective Detail
- Large progress ring
- Description, owner, priority, status
- List of Key Results, each showing:
  - Title, progress bar, current/target values
  - Assignee avatar
  - "Update" button → manual progress entry
  - Recent entries (with source: manual/lark indicator)
- Edit button → modify objective
- Add Key Result button

#### 4. Family Members
- List with avatar, name, role, personal progress ring
- Tap → Member Detail:
  - Profile header
  - Their assigned objectives + key results
  - Their activity feed
- Add/edit members
- Lark User ID field (for bot matching)

#### 5. Activity Feed
- Chronological list of all updates
- Each entry shows:
  - Member avatar + name
  - What was updated and by how much
  - Source badge (app icon or Lark icon)
  - Timestamp
  - Original Lark message (if from bot)

#### 6. Settings
- Year selector (2026, 2027, ...)
- Manage family members
- Lark integration status
- Load sample data / Reset data

---

## VPS Server (Node.js / TypeScript)

### Tech Stack
- **Runtime:** Node.js + TypeScript
- **Framework:** Express or Hono
- **LLM:** Claude-compatible API (min cost model for parsing)
- **CloudKit:** apple-cloudkit or REST API with Server-to-Server auth
- **Database:** SQLite (local cache on VPS, source of truth is CloudKit)

### Components

#### 1. Lark Bot Webhook Handler

```
POST /webhook/lark
```

Receives Lark event callbacks when messages are sent in the group chat.

Flow:
1. Verify Lark webhook signature
2. Extract message text + sender open_id
3. Ignore bot's own messages
4. Pass to LLM Agent for parsing
5. If parsed successfully → write to CloudKit
6. Reply in Lark group with confirmation or clarification

#### 2. LLM Agent

Responsible for parsing natural language messages into structured OKR updates.

**Input:** raw message text + current OKR context (objectives, key results, members)

**System prompt:**
```
You are a family OKR tracking assistant. Parse the user's message
to identify an OKR progress update.

Current family OKR data:
{objectives_and_key_results_json}

Family members:
{members_json}

The message sender is: {sender_name}

Parse the message and return JSON:
{
  "type": "update" | "query" | "unrelated",
  "keyResultId": "uuid or null",
  "delta": number or null,
  "absoluteValue": number or null,
  "confidence": 0.0 to 1.0,
  "reply": "human-friendly confirmation message"
}

Rules:
- If the message is clearly an OKR progress update, parse it
- If ambiguous, set confidence < 0.8 and ask for clarification in reply
- If unrelated to OKR, set type to "unrelated"
- Delta means incremental (+5km), absoluteValue means set to exact value
- Match the message to the most relevant key result
```

**Confidence handling:**
- confidence >= 0.8 → auto-update, reply with confirmation
- confidence 0.5-0.8 → reply asking for confirmation ("Did you mean X?")
- confidence < 0.5 or type "unrelated" → ignore silently or reply briefly

#### 3. CloudKit Server-to-Server Writer

Uses CloudKit Web Services REST API with server-to-server authentication.

Operations:
- **Read:** Fetch current objectives, key results, members (for LLM context)
- **Write:** Create ProgressEntry record, update KeyResult.currentValue
- **Write:** Create ActivityLog entry

Authentication:
- Server-to-Server key pair (generated in Apple Developer portal)
- Signs requests with ES256 JWT

#### 4. OKR Context Cache

To avoid reading CloudKit on every message:
- Cache OKR data in memory/SQLite on VPS
- Refresh cache every 5 minutes or on-demand
- Invalidate on write

### API Endpoints

| Method | Path              | Purpose                           |
|--------|-------------------|-----------------------------------|
| POST   | /webhook/lark     | Lark event callback               |
| GET    | /health           | Health check                      |
| POST   | /sync/refresh     | Force refresh OKR cache from CloudKit |

### Lark Bot Reply Examples

**Successful update:**
```
Done! Updated "Running distance" +5km
Progress: 89/200 km (44%)
```

**Needs clarification:**
```
I'm not sure which goal this relates to. Did you mean:
1. Running distance (currently 84/200 km)
2. Exercise sessions (currently 45/200)
Reply with 1 or 2.
```

**Status query ("how are we doing"):**
```
Family OKR 2026 Progress:

Healthier Lifestyle — 52%
  Running 200km: 89/200 (44%)
  Cook at home 300x: 167/300 (56%)
  Read 50 books: 28/50 (56%)

Financial Freedom — 63%
  Save $20k: $12,500 (63%)

Overall: 55% | 182 days remaining
```

**Unrelated message:** No reply (bot stays silent)

---

## CloudKit Setup

### Prerequisites
1. Apple Developer account (already have)
2. Create CloudKit container: `iCloud.com.yourteam.familyokr`
3. Define record types in CloudKit Dashboard matching the data model
4. Generate Server-to-Server key in Apple Developer portal

### CloudKit Record Types

```
FamilyMember:
  name          String
  role          String
  avatarEmoji   String
  colorHex      String
  larkUserId    String

Objective:
  title         String
  description   String
  year          Int64
  icon          String
  priority      String
  owner         Reference → FamilyMember

KeyResult:
  title         String
  targetValue   Double
  currentValue  Double
  unit          String
  objective     Reference → Objective
  assignee      Reference → FamilyMember

ProgressEntry:
  delta         Double
  newValue      Double
  note          String
  source        String
  rawMessage    String
  keyResult     Reference → KeyResult
  member        Reference → FamilyMember

ActivityLog:
  type          String
  summary       String
  source        String
  member        Reference → FamilyMember
  objective     Reference → Objective
  keyResult     Reference → KeyResult
```

### CloudKit Zones
- Use a **custom zone** (`FamilyOKRZone`) in the private database
- This enables atomic writes and change tracking
- SwiftData with CloudKit uses `CKShare` for sharing between family members

### Sharing Strategy
- One family member creates the data (e.g. a parent)
- Share the CloudKit zone with other family members via `CKShare`
- All members have read/write access
- VPS uses the zone owner's Server-to-Server credentials to write

---

## Project Structure

```
/FamilyOKR
├── app/                          # SwiftUI App
│   ├── FamilyOKR.xcodeproj
│   └── FamilyOKR/
│       ├── FamilyOKRApp.swift    # App entry, CloudKit container
│       ├── Models/
│       │   ├── FamilyMember.swift
│       │   ├── Objective.swift
│       │   ├── KeyResult.swift
│       │   ├── ProgressEntry.swift
│       │   └── ActivityLog.swift
│       ├── ViewModels/
│       │   └── OKRStore.swift
│       ├── Views/
│       │   ├── ContentView.swift
│       │   ├── Dashboard/
│       │   │   └── DashboardView.swift
│       │   ├── Objectives/
│       │   │   ├── ObjectivesListView.swift
│       │   │   ├── ObjectiveDetailView.swift
│       │   │   ├── AddObjectiveView.swift
│       │   │   ├── EditObjectiveView.swift
│       │   │   ├── AddKeyResultView.swift
│       │   │   └── UpdateKeyResultView.swift
│       │   ├── Members/
│       │   │   ├── MembersListView.swift
│       │   │   ├── MemberDetailView.swift
│       │   │   └── AddMemberView.swift
│       │   ├── Activity/
│       │   │   └── ActivityFeedView.swift
│       │   ├── Settings/
│       │   │   └── SettingsView.swift
│       │   └── Components/
│       │       ├── ProgressRing.swift
│       │       ├── StatusBadge.swift
│       │       ├── PeriodPicker.swift
│       │       └── FilterChips.swift
│       ├── Resources/
│       │   └── Assets.xcassets
│       └── Info.plist
│
├── server/                       # VPS Server
│   ├── package.json
│   ├── tsconfig.json
│   ├── src/
│   │   ├── index.ts              # Entry point
│   │   ├── config.ts             # Environment config
│   │   ├── lark/
│   │   │   ├── webhook.ts        # Lark webhook handler
│   │   │   ├── client.ts         # Lark API client (send replies)
│   │   │   └── types.ts          # Lark event types
│   │   ├── llm/
│   │   │   ├── agent.ts          # LLM message parser
│   │   │   ├── prompt.ts         # System prompt builder
│   │   │   └── types.ts          # Parse result types
│   │   ├── cloudkit/
│   │   │   ├── client.ts         # CloudKit S2S API client
│   │   │   ├── auth.ts           # JWT signing for S2S
│   │   │   ├── records.ts        # CRUD operations
│   │   │   └── types.ts          # CloudKit record types
│   │   └── cache/
│   │       └── okrCache.ts       # In-memory OKR data cache
│   ├── .env.example
│   └── Dockerfile
│
└── docs/
    └── DESIGN.md                 # This file
```

---

## Implementation Phases

### Phase 1: SwiftUI App + CloudKit Sync
- SwiftData models with CloudKit integration
- All screens: Dashboard, Objectives, Members, Activity, Settings
- Manual progress updates in-app
- iCloud sync across family devices
- CloudKit sharing setup

### Phase 2: VPS Server + Lark Bot
- Node.js/TS server with Express/Hono
- Lark webhook handler
- LLM agent for message parsing
- CloudKit S2S integration (read OKR context, write updates)
- Bot reply messages in Lark group

### Phase 3: Polish
- Error handling and retry logic
- Bot clarification flow (confidence < 0.8)
- Status query support ("how are we doing")
- Activity feed with Lark message source
- Cache optimization

---

## Environment Variables (VPS)

```env
# Lark Bot
LARK_APP_ID=cli_xxxx
LARK_APP_SECRET=xxxx
LARK_VERIFICATION_TOKEN=xxxx
LARK_ENCRYPT_KEY=xxxx

# LLM (Claude-compatible API)
LLM_API_URL=https://api.anthropic.com/v1
LLM_API_KEY=sk-xxxx
LLM_MODEL=claude-haiku-4-5-20251001

# CloudKit Server-to-Server
CLOUDKIT_CONTAINER=iCloud.com.yourteam.familyokr
CLOUDKIT_KEY_ID=xxxx
CLOUDKIT_PRIVATE_KEY_PATH=./keys/cloudkit-s2s.pem
CLOUDKIT_ENVIRONMENT=production

# Server
PORT=3000
NODE_ENV=production
```
