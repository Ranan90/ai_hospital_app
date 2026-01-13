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
  const { id, name, email, phone, height_cm, weight_kg, dob } = req.body;

  try {
    // 1. If we have an ID, update existing profile or create if not exists
    // The frontend sends user_id if logged in.
    
    // Note: 'profiles' table usually linked to auth.users via id.
    // If we rely on passed 'id', ensure it matches.
    
    // Upsert into profiles
    const { data, error } = await supabase
      .from("profiles")
      .upsert({
         id, 
         name, 
         email, 
         phone, 
         height_cm, 
         weight_kg, 
         dob,
         updated_at: new Date().toISOString()
      })
      .select()
      .single();

    if (error) throw error;
    res.json(data);

  } catch (err) {
    console.error("Profile Error:", err);
    res.status(500).json({ error: "Failed to create/update user profile" });
  }
});

/* 2️⃣ AI symptom check */
app.post("/symptom-check", async (req, res) => {
  const { user_id, answers } = req.body; // user_id passed from frontend
  // answers = { fever: 'yes', chest_pain: 'no', ... } or list of strings

  try {
    const prompt = `
You are a hospital triage AI.

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
    // Parse JSON from AI response safely? 
    // For now assuming content is JSON or simple string if AI fails to format.
    // The prompt asks for JSON.

    let resultData;
    let department = "General Medicine";

    try {
        // Strip markdown code blocks if present
        const jsonStr = content.replace(/^```json\n|\n```$/g, '');
        resultData = JSON.parse(jsonStr);
        department = resultData.department || department;
    } catch (e) {
        console.warn("AI didn't return valid JSON", content);
    }
    
    // Save to Supabase
    if (user_id) {
       await supabase.from("symptom_checks").insert({
          user_id: user_id,
          symptoms: answers,
          result_department: department,
          metadata: resultData || { raw: content }
       });
    }

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
