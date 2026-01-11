import { createClient } from "@supabase/supabase-js";
import cors from "cors";
import "dotenv/config";
import express from "express";
import OpenAI from "openai";

const app = express();
app.use(cors());
app.use(express.json());

const supabase = createClient(
  process.env.SUPABASE_URL,
  process.env.SUPABASE_SERVICE_ROLE_KEY
);

const openai = new OpenAI({
  apiKey: process.env.OPENAI_API_KEY,
});

/* 1️⃣ Get or update user info (height & weight editable) */
app.post("/user", async (req, res) => {
  const { name, email, phone, height_cm, weight_kg, dob } = req.body;

  try {
    // Check if user exists
    const { data: existing } = await supabase
      .from("users")
      .select("*")
      .eq("email", email)
      .single();

    if (existing) {
      // Update height & weight if provided
      const { data, error } = await supabase
        .from("users")
        .update({ height_cm, weight_kg })
        .eq("id", existing.id)
        .select()
        .single();
      if (error) throw error;
      return res.json(data);
    }

    // Create new user
    const { data, error } = await supabase
      .from("users")
      .insert({ name, email, phone, height_cm, weight_kg, dob })
      .select()
      .single();
    if (error) throw error;
    res.json(data);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: "Failed to create/update user" });
  }
});

/* 2️⃣ AI symptom check */
app.post("/symptom-check", async (req, res) => {
  const { user, answers } = req.body;
  // answers = { fever: 'yes', chest_pain: 'no', ... }

  try {
    const prompt = `
You are a hospital triage AI.

User info:
${JSON.stringify(user)}

User symptoms:
${JSON.stringify(answers)}

Ask follow-up questions if needed.
If enough info collected, reply with one of these departments:
General Medicine, Orthopedics, Cardiology, Neurology, Dermatology.
If unsure, reply "General Medicine".

Reply in JSON format:
{
  "next_question": "question text or null if done",
  "department": "predicted department or null if more questions needed"
}
`;

    const aiRes = await openai.chat.completions.create({
      model: "gpt-4o-mini",
      messages: [{ role: "user", content: prompt }],
    });

    const content = aiRes.choices[0].message.content.trim();

    const department =
      aiRes.choices?.[0]?.message?.content?.trim() ?? "General Medicine";

    res.json({ department });
  } catch (err) {
    console.error("Ai Error: ", err.message);
    res.status(500).json({
      error: "AI failed",
      message: "Ai service is currently unavailable. Please try again",
    });
  }
});

app.listen(process.env.PORT || 3000, () =>
  console.log(`Backend running on port ${process.env.PORT || 3000}`)
);
