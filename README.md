# 🏥 AI Hospital App

A full-stack AI-powered hospital management application built with **Flutter** (frontend) and **Node.js + Express** (backend). It leverages **Google Gemini AI** for intelligent medical triage and **Supabase** for authentication and database management.

---

## 📋 Table of Contents

- [Features](#-features)
- [Tech Stack](#-tech-stack)
- [Project Structure](#-project-structure)
- [Architecture Overview](#-architecture-overview)
- [Getting Started](#-getting-started)
  - [Prerequisites](#prerequisites)
  - [Backend Setup](#backend-setup)
  - [Frontend Setup](#frontend-setup)
- [Environment Variables](#-environment-variables)
- [API Reference](#-api-reference)
- [Database Schema](#-database-schema)
- [Screens & Navigation](#-screens--navigation)

---

## ✨ Features

### Patient Side
- 🔐 **Authentication** — Sign up / Log in via Supabase Auth
- 👤 **Personal Profile** — Store height, weight, date of birth, and contact info
- 🤖 **AI Triage Chat** — Conversational AI (Gemini) that gathers symptoms and recommends a hospital department with urgency level
- 🏨 **Department & Doctor View** — Browse recommended department info and available doctors filtered by today's time slots
- 📅 **Appointment Booking** — Book morning or evening slots with available doctors
- 📞 **Live Care / Call** — In-app call type selection and dummy call screens

### Doctor Side
- 🩺 **Doctor Login** — Separate login portal for doctors
- 📊 **Dashboard** — View scheduled appointments for the next 7 days
- 🗓️ **Availability Management** — Toggle morning/evening slot availability per day

---

## 🛠 Tech Stack

| Layer      | Technology                                                              |
|------------|-------------------------------------------------------------------------|
| Frontend   | Flutter (Dart) · Supabase Flutter · HTTP                                |
| Backend    | Node.js · Express.js (v5) · ES Modules                                  |
| AI         | Google Gemini (`gemini-3-flash-preview`) via `@google/genai`            |
| Database   | Supabase (PostgreSQL)                                                   |
| Auth       | Supabase Auth                                                           |
| Other      | CORS · dotenv                                                           |

---

## 📁 Project Structure

```
ai_hospital_app/
├── backend/                  # Node.js Express API server
│   ├── index.js              # All API routes & Gemini/Supabase logic
│   ├── package.json          # Node dependencies
│   ├── .env                  # Environment variables (not committed)
│   └── .gitignore
│
└── frontend/                 # Flutter application
    ├── lib/
    │   ├── main.dart              # App entry point, Supabase init
    │   ├── config/
    │   │   └── api_config.dart    # Base URL config (Android emulator / desktop)
    │   ├── models/
    │   │   ├── doctor_models.dart # Doctor & appointment data models
    │   │   └── triage_models.dart # AI triage response models
    │   └── features/
    │       ├── ai/
    │       │   ├── ai_screen.dart         # AI chat interface
    │       │   ├── ai_results_screen.dart # Triage conclusion & department result
    │       │   └── ai_service.dart        # HTTP calls to /ai/chat
    │       ├── doctor/
    │       │   └── doctor_dashboard_screen.dart  # Doctor appointments & availability
    │       ├── screens/
    │       │   ├── home_screen.dart            # Main hub screen
    │       │   ├── auth_screen.dart            # Auth gate (checks session)
    │       │   ├── login_screen.dart           # Patient login
    │       │   ├── signup_screen.dart          # Patient registration
    │       │   ├── personal_details_screen.dart# Profile setup
    │       │   ├── ai_chat_screen.dart         # Chat UI wrapper
    │       │   ├── call_type_screen.dart       # Select call type
    │       │   ├── live_care_screen.dart       # Live care options
    │       │   └── dummy_call_screens.dart     # Placeholder call UI
    │       └── services/
    │           └── api_service.dart            # General HTTP service layer
    └── pubspec.yaml
```

---

## 🏗 Architecture Overview

```
┌─────────────────────────────────────────────────────────┐
│                     Flutter App                          │
│   (Screens → Services → HTTP → Backend API)             │
└────────────────────┬────────────────────────────────────┘
                     │  REST (JSON)
                     ▼
┌─────────────────────────────────────────────────────────┐
│               Node.js / Express Backend                  │
│                                                         │
│  POST /user                  → Upsert patient profile   │
│  POST /ai/chat               → Gemini AI triage         │
│  POST /api/department-details→ Dept info + doctors      │
│  POST /api/doctor/login      → Doctor authentication    │
│  POST /api/doctor/dashboard  → Appointments + avail.    │
│  POST /api/doctor/availability → Update slot avail.     │
└────────┬───────────────────────────┬────────────────────┘
         │                           │
         ▼                           ▼
  ┌─────────────┐            ┌──────────────────┐
  │  Supabase   │            │  Google Gemini   │
  │ (PostgreSQL │            │   AI (Flash)     │
  │   + Auth)   │            └──────────────────┘
  └─────────────┘
```

---

## 🚀 Getting Started

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) ≥ 3.10
- [Node.js](https://nodejs.org/) ≥ 18
- A [Supabase](https://supabase.com/) project with the required tables
- A [Google AI Studio](https://aistudio.google.com/) API key (Gemini)

---

### Backend Setup

1. **Navigate to the backend folder:**
   ```bash
   cd backend
   ```

2. **Install dependencies:**
   ```bash
   npm install
   ```

3. **Create the `.env` file** (see [Environment Variables](#-environment-variables)):
   ```bash
   cp .env.example .env   # or create manually
   ```

4. **Start the server:**
   ```bash
   node index.js
   ```
   The server will start on `http://localhost:3000` by default.

---

### Frontend Setup

1. **Navigate to the frontend folder:**
   ```bash
   cd frontend
   ```

2. **Install Flutter dependencies:**
   ```bash
   flutter pub get
   ```

3. **Configure Supabase** in `lib/main.dart`:
   ```dart
   await Supabase.initialize(
     url: 'YOUR_SUPABASE_URL',
     anonKey: 'YOUR_SUPABASE_ANON_KEY',
   );
   ```

4. **Configure the backend URL** in `lib/config/api_config.dart`:
   - **Android Emulator:** automatically uses `http://10.0.2.2:3000`
   - **Other platforms:** defaults to `http://localhost:3000`, or pass `--dart-define=API_URL=http://your-server:3000`

5. **Run the app:**
   ```bash
   flutter run
   ```
   Or target a specific device:
   ```bash
   flutter run -d android
   flutter run -d chrome
   flutter run -d windows
   ```

---

## 🔑 Environment Variables

Create a `.env` file inside the `backend/` directory:

```env
# Server port (optional, defaults to 3000)
PORT=3000

# Supabase
SUPABASE_URL=https://your-project-id.supabase.co
SUPABASE_SERVICE_ROLE_KEY=your_service_role_key

# Google Gemini AI
GEMINI_API_KEY=your_gemini_api_key
```

> ⚠️ **Never commit your `.env` file.** It is already listed in `.gitignore`.

---

## 📡 API Reference

All endpoints accept and return `application/json`.

### `POST /user`
Create or update a patient profile.

**Request body:**
```json
{
  "id": "uuid",
  "name": "John Doe",
  "email": "john@example.com",
  "phone": "1234567890",
  "height": 175,
  "weight": 70,
  "dob": "1995-06-15"
}
```

---

### `POST /ai/chat`
Send a message to the Gemini medical triage assistant.

**Request body:**
```json
{
  "history": [
    { "role": "user", "content": "I have a severe headache" }
  ],
  "userProfile": {
    "height": 175,
    "weight": 70,
    "dob": "1995-06-15"
  }
}
```

**Response:**
```json
{
  "status": "gathering_info | conclusion",
  "message": "AI response text",
  "recommendedDepartment": "Neurology",
  "reasoning": "Explanation...",
  "urgency": "low | medium | high | emergency"
}
```

---

### `POST /api/department-details`
Get department info and available doctors for today.

**Request body:**
```json
{
  "departmentName": "Neurology",
  "clientHour": 10
}
```

**Response:**
```json
{
  "about": "Department description...",
  "doctors": [
    {
      "id": "uuid",
      "name": "Dr. Smith",
      "experience": 12,
      "morning": true,
      "evening": false
    }
  ]
}
```

---

### `POST /api/doctor/login`
Authenticate a doctor.

**Request body:**
```json
{
  "email": "doctor@hospital.com",
  "password": "plaintext_password"
}
```

**Response:**
```json
{
  "success": true,
  "doctor": { ...doctorObject }
}
```

---

### `POST /api/doctor/dashboard`
Fetch a doctor's upcoming appointments and 7-day availability.

**Request body:**
```json
{ "doctorId": "doctor-uuid" }
```

**Response:**
```json
{
  "appointments": [...],
  "availability": [
    {
      "date": "2026-07-01",
      "morning": { "available": true, "booked": false },
      "evening": { "available": false, "booked": false }
    }
  ]
}
```

---

### `POST /api/doctor/availability`
Update a doctor's morning/evening slot availability for a given date.

**Request body:**
```json
{
  "doctorId": "doctor-uuid",
  "date": "2026-07-01",
  "morning": true,
  "evening": false
}
```

---

## 🗄 Database Schema

The following Supabase tables are required:

| Table                  | Key Columns                                                                 |
|------------------------|-----------------------------------------------------------------------------|
| `profiles`             | `id`, `name`, `email`, `phone`, `height`, `weight`, `dob`, `updated_at`    |
| `departments`          | `id`, `name`, `about`                                                       |
| `doctors`              | `id`, `name`, `email`, `password`, `department_id`, `years_of_experience`  |
| `doctor_availability`  | `doctor_id`, `date`, `morning_slot_available`, `evening_slot_available`     |
| `appointments`         | `id`, `patient_id`, `doctor_id`, `appointment_date`, `slot_type`, `status` |

---

## 📱 Screens & Navigation

| Screen                        | Description                                              |
|-------------------------------|----------------------------------------------------------|
| `HomeScreen`                  | Landing hub — navigate to AI triage, live care, doctor portal |
| `AuthScreen`                  | Checks existing Supabase session and routes accordingly  |
| `LoginScreen`                 | Patient email/password login                             |
| `SignupScreen`                | Patient registration                                     |
| `PersonalDetailsScreen`       | Collect and save patient health profile                  |
| `AiScreen` / `AiChatScreen`   | Conversational triage chat with Gemini AI                |
| `AiResultsScreen`             | Show triage conclusion, department, and urgency          |
| `LiveCareScreen`              | Live care options                                        |
| `CallTypeScreen`              | Select call type (audio/video)                           |
| `DummyCallScreens`            | Placeholder in-app call UI                               |
| `DoctorDashboardScreen`       | Doctor's appointment list and availability toggle        |

---

## 📄 License

This project is for educational and demonstration purposes.








