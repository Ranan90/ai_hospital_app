import * as chat from "@botpress/chat";
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
    const { history } = req.body;

    const contents = history.map((m) => ({
      role: m.role === "user" ? "user" : "model",
      parts: [{ text: m.content }],
    }));

    const response = await ai.models.generateContent({
      model: "gemini-3-flash-preview",
      contents,
      config: {
        systemInstruction: SYSTEM_INSTRUCTION,
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
   Server
======================= */
app.listen(process.env.PORT || 3000, () =>
  console.log(`Backend running on port ${process.env.PORT || 3000}`)
);
