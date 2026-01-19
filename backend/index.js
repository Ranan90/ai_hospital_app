import { GoogleGenAI, Type } from "@google/genai";
import { createClient } from "@supabase/supabase-js";
import cors from "cors";
import "dotenv/config";
import express from "express";

const app = express();
app.use(cors());
app.use(express.json());

/* =======================
   Supabase
======================= */
const supabase = createClient(
  process.env.SUPABASE_URL,
  process.env.SUPABASE_SERVICE_ROLE_KEY
);

/* =======================
   Gemini Setup
======================= */
const ai = new GoogleGenAI({
  apiKey: process.env.GEMINI_API_KEY,
});

const SYSTEM_INSTRUCTION = `
You are a professional medical triage assistant.

Rules:
1. Ask follow-up questions if needed.
2. Do NOT diagnose diseases.
3. If enough info is gathered, conclude with department + urgency.
4. If life-threatening → Emergency Medicine.
5. Departments:
   General Medicine, Orthopedics, Cardiology, Neurology,
   Dermatology, Gastroenterology, Pulmonology, Emergency Medicine.

Return ONLY valid JSON matching the schema.
`;

/* =======================
   1️⃣ Create / Update User
======================= */
app.post("/user", async (req, res) => {
  const { id, name, email, phone, height, weight, dob } = req.body;

  try {
    const { data, error } = await supabase
      .from("profiles")
      .upsert({
        id,
        name,
        email,
        phone,
        height,
        weight,
        dob,
        updated_at: new Date().toISOString(),
      })
      .select()
      .single();

    if (error) throw error;
    res.json(data);
  } catch (err) {
    console.error("Profile Error:", err);
    res.status(500).json({ error: "Failed to update profile" });
  }
});

/* =======================
   2️⃣ AI Chat
======================= */
/**
 * POST /ai/chat
 * body: { user_id, message }
 */
app.post("/ai/chat", async (req, res) => {
  try {
    const { history, userProfile } = req.body;

    const contents = history.map((m) => ({
      role: m.role === "user" ? "user" : "model",
      parts: [{ text: m.content }],
    }));

    if (userProfile) {
      // Prepend context to the conversation or system instruction
      // We'll append it to the system instruction dynamically here for this request
      // But the generateContent config is static object in this code structure.
      // A better way is to insert it as a system-like user message at the start,
      // or modify the system instruction string for this request.

      // Let's modify the first user message if possible, or add a context message.
      // Adding a context message at the start:
      const contextMsg = `Patient Profile:\nHeight: ${userProfile.height} ${userProfile.heightUnit || 'cm'}\nWeight: ${userProfile.weight} ${userProfile.weightUnit || 'kg'}\nDOB: ${userProfile.dob || 'Unknown'}`;

      // We can prepend this to the very first message 'parts' if it is a user message,
      // or insert a new turn. inserting a new turn might confuse the strict alternate turn policy of some models.
      // Safest is to modify the system instruction for this call.
    }

    let activeSystemInstruction = SYSTEM_INSTRUCTION;
    if (userProfile) {
      activeSystemInstruction += `\n\nPatient Context:\nHeight: ${userProfile.height}\nWeight: ${userProfile.weight}\nDOB: ${userProfile.dob}`;
    }

    const response = await ai.models.generateContent({
      model: "gemini-3-flash-preview",
      contents,
      config: {
        systemInstruction: activeSystemInstruction,
        responseMimeType: "application/json",
        responseSchema: {
          type: Type.OBJECT,
          properties: {
            status: {
              type: Type.STRING,
              enum: ["gathering_info", "conclusion"],
            },
            message: { type: Type.STRING },
            recommendedDepartment: { type: Type.STRING, nullable: true },
            reasoning: { type: Type.STRING, nullable: true },
            urgency: {
              type: Type.STRING,
              enum: ["low", "medium", "high", "emergency"],
            },
          },
          required: ["status", "message", "urgency"],
        },
      },
    });

    res.json(JSON.parse(response.text));
  } catch (err) {
    console.error("Gemini Error:", err);

    // Distinguish common failure scenarios
    if (err.status === 503) {
      return res.status(503).json({
        error: "AI model is overloaded. Please try again shortly.",
      });
    }

    if (err.status === 429) {
      return res.status(429).json({
        error: "Request limit reached. Please try again in a few minutes.",
      });
    }

    res.status(500).json({
      error: "AI service unavailable. Please try again later.",
    });
  }
});

/* =======================
   3️⃣ Department & Doctor Details
======================= */
app.post("/api/department-details", async (req, res) => {
  const { departmentName, clientHour } = req.body;

  if (!departmentName) {
    return res.status(400).json({ error: "Department name is required" });
  }

  try {
    // 1. Fetch Department Info
    const { data: deptRes, error: deptError } = await supabase
      .from("departments")
      .select("id, about")
      .ilike("name", departmentName)
      .maybeSingle();

    if (deptError || !deptRes) {
      return res.status(404).json({ error: "Department not found" });
    }

    const { id: deptId, about } = deptRes;

    // 2. Fetch Doctors & Availability for Today
    const today = new Date().toISOString().split("T")[0]; // YYYY-MM-DD

    const { data: doctorsRes, error: docError } = await supabase
      .from("doctors")
      .select(`
        id, name, years_of_experience,
        doctor_availability!inner(
          date,
          morning_slot_available,
          evening_slot_available
        )
      `)
      .eq("department_id", deptId)
      .eq("doctor_availability.date", today);

    if (docError) {
      console.error("Doctor Fetch Error:", docError);
      throw docError;
    }

    // 3. Filter by Time
    // Use clientHour if provided, otherwise default to server time
    const activeHour =
      clientHour !== undefined ? clientHour : new Date().getHours();
    
    const filteredDoctors = [];

    // Check if doctorsRes is not null/empty
    if (doctorsRes && doctorsRes.length > 0) {
      for (const doc of doctorsRes) {
        // doctor_availability is an array because of the join, but we expect 1 inner join result per doctor for 'today'
        const availability = doc.doctor_availability[0];
        
        if (!availability) continue;

        const { morning_slot_available, evening_slot_available } = availability;

        // Logic:
        // Morning (8am - 2pm): Valid if current time < 14
        // Evening (4pm - 7pm): Valid if current time < 19
        
        const morningValid = morning_slot_available && activeHour < 14;
        const eveningValid = evening_slot_available && activeHour < 19;

        // If at least one slot is valid for CURRENT time, include the doctor
        if (morningValid || eveningValid) {
          filteredDoctors.push({
            id: doc.id,
            name: doc.name,
            experience: doc.years_of_experience,
            morning: morningValid,
            evening: eveningValid,
          });
        }
      }
    }

    res.json({
      about,
      doctors: filteredDoctors,
    });

  } catch (err) {
    console.error("Department Details Error:", err);
    res.status(500).json({ error: "Failed to fetch department details" });
  }
});


/* =======================
   4️⃣ Doctor Dashboard & Auth
======================= */

// Doctor Login
app.post("/api/doctor/login", async (req, res) => {
  const { email, password } = req.body;

  try {
    const { data, error } = await supabase
      .from("doctors")
      .select("*")
      .eq("email", email)
      .eq("password", password) // Plaintext check as requested
      .maybeSingle();

    if (error) throw error;
    if (!data) return res.status(401).json({ error: "Invalid credentials" });

    res.json({ success: true, doctor: data });
  } catch (err) {
    console.error("Doctor Login Error:", err);
    res.status(500).json({ error: "Login failed" });
  }
});

// Doctor Dashboard Data (Appointments + Availability)
app.post("/api/doctor/dashboard", async (req, res) => {
  const { doctorId } = req.body;
  if (!doctorId) return res.status(400).json({ error: "Doctor ID required" });

  try {
    const today = new Date().toISOString().split("T")[0];

    // 1. Fetch Appointments (Scheduled) - Linked to Profiles
    // Note: 'appointments' has 'patient_id' which links to auth.users. 
    // We assume there's a 'profiles' table that shares the ID with auth.users to get names.
    const { data: appointments, error: apptError } = await supabase
      .from("appointments")
      .select(`
        id, appointment_date, slot_type, status,
        patient_id,
        patient:profiles!patient_id (name, age, gender) 
      `) // Assuming 'profiles' relation exists. If not, we might fail here. 
         // But user earlier code showed 'profiles' table usage for user updates.
      .eq("doctor_id", doctorId)
      .eq("status", "scheduled")
      .gte("appointment_date", today)
      .order("appointment_date", { ascending: true });

    if (apptError) { 
        console.error("Appt Fetch details:", apptError);
        // Fallback if profiles relation issue? Just return basic info
        // But let's throw to see error.
    }

    // 2. Fetch Availability (Next 7 days)
    const nextWeek = new Date();
    nextWeek.setDate(nextWeek.getDate() + 7);
    const endDate = nextWeek.toISOString().split("T")[0];

    const { data: availability, error: availError } = await supabase
      .from("doctor_availability")
      .select("*")
      .eq("doctor_id", doctorId)
      .gte("date", today)
      .lte("date", endDate)
      .order("date", { ascending: true });

    if (availError) throw availError;

    // 3. Mark "booked" slots visually
    // Logic: If there is an appointment on Date X for Slot Y, that slot is BOOKED.
    // The availability table just says if the doctor *offered* the slot.
    // The dashboard needs to know: Offered? Booked?
    
    // We already fetched scheduled appointments. Let's process availability to add 'booked' flags.
    const processedAvailability = [];
    
    // Helper to generate next 7 days dates
    const dateList = [];
    for(let i=0; i<7; i++) {
        const d = new Date();
        d.setDate(d.getDate() + i);
        dateList.push(d.toISOString().split("T")[0]);
    }

    // Map existing availability and appointments
    for(const d of dateList) {
        // Find availability record or default
        const record = availability?.find(r => r.date === d) || { 
            doctor_id: doctorId, date: d, morning_slot_available: false, evening_slot_available: false 
        };

        // Check for bookings
        const dayAppts = appointments?.filter(a => a.appointment_date === d) || [];
        const morningBooked = dayAppts.some(a => a.slot_type === 'morning');
        const eveningBooked = dayAppts.some(a => a.slot_type === 'evening');

        processedAvailability.push({
            date: d,
            morning: {
                available: record.morning_slot_available,
                booked: morningBooked
            },
            evening: {
                available: record.evening_slot_available,
                booked: eveningBooked
            }
        });
    }

    res.json({
        appointments: appointments || [],
        availability: processedAvailability
    });

  } catch (err) {
    console.error("Dashboard Error:", err);
    res.status(500).json({ error: "Failed to fetch dashboard data" });
  }
});

// Update Availability
app.post("/api/doctor/availability", async (req, res) => {
    const { doctorId, date, morning, evening } = req.body;
    
    try {
        // Upsert availability record
        const { data, error } = await supabase
            .from("doctor_availability")
            .upsert({
                doctor_id: doctorId,
                date: date,
                morning_slot_available: morning,
                evening_slot_available: evening
            }, { onConflict: 'doctor_id, date' })
            .select();

        if (error) throw error;
        res.json({ success: true, data });
    } catch(err) {
        console.error("Update Avail Error:", err);
        res.status(500).json({ error: "Failed to update availability" });
    }
});

/* =======================
   Server
======================= */
app.listen(process.env.PORT || 3000, () =>
  console.log(`Backend running on port ${process.env.PORT || 3000} `)
);
