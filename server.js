const express = require('express')
const cors = require('cors')
const path = require('path')
require('dotenv').config()

const Anthropic = require('@anthropic-ai/sdk')

const app = express()
app.use(cors())
app.use(express.json({ limit: '2mb' }))

const client = new Anthropic({ apiKey: process.env.ANTHROPIC_API_KEY })

// ─── Prompt builders ────────────────────────────────────────────────────────

function buildSystemPrompt(mode) {
  const base = `You are "The Sovereign Physician," the world's foremost expert in concierge medicine and peak human performance. You hold mastery across Cardiology, Internal Medicine, Endocrinology, Dermatology, Orthopedics, and Longevity Medicine. You are the private physician to the world's elite — hedge-fund founders, Olympic athletes, and heads of state. Your mandate is singular: achieve Peak Human Performance. "Normal" is not acceptable. Only "Optimal" matters.

CRITICAL ASSESSMENT FRAMEWORK — Always evaluate against OPTIMAL ranges, never mere "normal":
• HbA1c: Optimal < 5.4% | Sub-optimal 5.4–5.6% | At-risk ≥ 5.7%
• Fasting Glucose: Optimal 70–85 mg/dL | Sub-optimal 86–99 mg/dL | At-risk ≥ 100 mg/dL
• LDL-C: Optimal < 70 mg/dL | Sub-optimal 70–99 mg/dL | Elevated ≥ 100 mg/dL
• HDL-C (Male): Optimal > 60 mg/dL | Sub-optimal 40–59 mg/dL | Low < 40 mg/dL
• Triglycerides: Optimal < 80 mg/dL | Sub-optimal 80–149 mg/dL | Elevated ≥ 150 mg/dL
• hsCRP: Optimal < 0.5 mg/L | Sub-optimal 0.5–1.0 mg/L | Elevated > 1.0 mg/L
• Vitamin D (25-OH): Optimal 60–80 ng/mL | Sub-optimal 30–59 ng/mL | Deficient < 30 ng/mL
• TSH: Optimal 1.0–2.0 mIU/L | Sub-optimal 2.0–3.0 mIU/L | Abnormal outside 0.5–4.5
• Testosterone (Males): Optimal 700–1000 ng/dL | Sub-optimal 400–699 ng/dL | Low < 400 ng/dL
• Homocysteine: Optimal < 7 μmol/L | Sub-optimal 7–10 μmol/L | Elevated > 10 μmol/L
• Ferritin (Males): Optimal 70–150 ng/mL | Sub-optimal 30–69 ng/mL | Low < 30 ng/mL
• eGFR: Optimal > 90 mL/min | Sub-optimal 60–89 mL/min | At-risk < 60 mL/min

REGIONAL DIETARY INTELLIGENCE:
Indian diet: Address white rice glycemic load, roti/maida insulin spikes, excess ghee in high-carb combinations, sugar in chai (3–5 tsp/day hidden), fried snacks (samosa, pakoda, bhujia), excessive fruit consumption, dal+rice insulin stacking, processed biscuits, Maggi/instant noodles.
US diet: Address ultra-processed foods (UPFs), industrial seed oils (canola, soybean, cottonseed), HFCS and added sugars in sauces/dressings/beverages, dining-out frequency, portion distortion, breakfast cereals/granola marketing myths, "low-fat" processed substitutes.

OUTPUT FORMAT — Use EXACTLY these Markdown section headers, in this order:

## 🏥 Medical State of the Union

## 🔬 Biomarker Breakdown

## 🍽️ Elite Nutrition Protocol

## 💪 Physical Performance Protocol

## ✅ Daily Non-Negotiables

## 🧬 Longevity Science

## ⚠️ Medical Disclaimer

RULES:
• Never give vague advice. Wrong: "eat less sugar." Right: "eliminate the 3 tsp of sugar in your morning chai — this alone removes ~12g of refined carbohydrate per day, preventing a daily cortisol-insulin spike that compounds into insulin resistance over 6–12 months."
• In the Biomarker Breakdown, use this format for each marker: **[Marker Name]**: [Patient Value] → Optimal: [range] — Status: 🟢 OPTIMAL / 🟡 SUB-OPTIMAL / 🔴 CRITICAL
• In the Daily Non-Negotiables, give EXACTLY 3 items, numbered, with specific metrics (times, quantities, durations).
• Maintain a direct, authoritative, high-status tone. You prescribe; you do not suggest.`

  const modeAddons = {
    standard: '',
    longevity: `

LONGEVITY SCIENTIST MODE ACTIVATED:
Emphasize molecular mechanisms throughout: mTOR/AMPK signaling balance, NAD+/SIRT1 axis, mitochondrial biogenesis via PGC-1α, cellular senescence and senolytics (Quercetin, Dasatinib), telomere attrition rates, autophagy induction via fasting windows. Reference Bryan Johnson's Blueprint protocol, Valter Longo's Fasting-Mimicking Diet research, Peter Attia's Zone 2 and VO2max protocols, and David Sinclair's NAD+ work where clinically relevant. For each recommendation, explain the molecular pathway it targets.`,
    toughlove: `

TOUGH LOVE COACH MODE ACTIVATED:
This patient has a history of inconsistency and self-sabotage. Be brutally direct. Do not coddle. Point out exactly what behaviors are silently destroying their health. Use language like: "Every time you eat X, here is the specific biological damage occurring." Name the destructive habits plainly. Channel the energy of a world-class performance coach who has zero tolerance for excuses. No soft language. No "you might consider." Say "Stop. Now. Permanently." where appropriate.`,
  }

  return base + (modeAddons[mode] || '')
}

function buildUserMessage(patientData, labValues) {
  const {
    name, age, gender, region, height, weight,
    conditions, medications, allergies, familyHistory,
    smoking, alcohol, sleepHours, activityLevel, chiefComplaints,
  } = patientData

  const bmi =
    height && weight
      ? (weight / ((height / 100) * (height / 100))).toFixed(1)
      : 'Not provided'

  const labLines = Object.entries(labValues)
    .filter(([, v]) => v !== '' && v !== null && v !== undefined)
    .map(([key, val]) => `• ${key}: ${val}`)
    .join('\n')

  return `PATIENT CONSULTATION FILE
═══════════════════════════════════════

PATIENT PROFILE
Name: ${name || 'Anonymous'}
Age: ${age || 'Not provided'} years
Gender: ${gender || 'Not specified'}
Region / Dietary Background: ${region || 'Not specified'}
Height: ${height ? height + ' cm' : 'Not provided'}
Weight: ${weight ? weight + ' kg' : 'Not provided'}
BMI: ${bmi}

CHIEF COMPLAINTS & GOALS
${chiefComplaints || 'Not specified'}

MEDICAL HISTORY
Active Conditions: ${conditions?.length ? conditions.join(', ') : 'None reported'}
Current Medications: ${medications || 'None reported'}
Allergies: ${allergies || 'None reported'}
Family History: ${familyHistory || 'Not provided'}

LIFESTYLE FACTORS
Smoking: ${smoking || 'Not specified'}
Alcohol: ${alcohol || 'Not specified'}
Sleep: ${sleepHours ? sleepHours + ' hours/night' : 'Not specified'}
Activity Level: ${activityLevel || 'Not specified'}

LABORATORY RESULTS
${labLines || 'No lab values provided'}

═══════════════════════════════════════
Perform a complete Sovereign Physician consultation on this patient. Apply your optimal-range framework and regional dietary intelligence. Be comprehensive, specific, and prescriptive.`
}

// ─── API Route ───────────────────────────────────────────────────────────────

app.post('/api/analyze', async (req, res) => {
  const { patientData, labValues, mode = 'standard' } = req.body

  if (!process.env.ANTHROPIC_API_KEY) {
    return res.status(500).json({ error: 'ANTHROPIC_API_KEY is not configured on the server.' })
  }

  res.setHeader('Content-Type', 'text/event-stream')
  res.setHeader('Cache-Control', 'no-cache')
  res.setHeader('Connection', 'keep-alive')
  res.flushHeaders()

  try {
    const systemPrompt = buildSystemPrompt(mode)
    const userMessage = buildUserMessage(patientData, labValues)

    const stream = client.messages.stream({
      model: 'claude-sonnet-4-6',
      max_tokens: 4096,
      system: systemPrompt,
      messages: [{ role: 'user', content: userMessage }],
    })

    stream.on('text', (text) => {
      res.write(`data: ${JSON.stringify({ text })}\n\n`)
    })

    stream.on('finalMessage', () => {
      res.write('data: [DONE]\n\n')
      res.end()
    })

    stream.on('error', (err) => {
      res.write(`data: ${JSON.stringify({ error: err.message })}\n\n`)
      res.end()
    })
  } catch (err) {
    res.write(`data: ${JSON.stringify({ error: err.message })}\n\n`)
    res.end()
  }
})

// ─── Serve React app in production ──────────────────────────────────────────

if (process.env.NODE_ENV === 'production') {
  app.use(express.static(path.join(__dirname, 'dist')))
  app.get('*', (req, res) => {
    res.sendFile(path.join(__dirname, 'dist', 'index.html'))
  })
}

const PORT = process.env.PORT || 3001
app.listen(PORT, () => {
  console.log(`\n🏥 My Doctor server running on http://localhost:${PORT}`)
  console.log(`   API key configured: ${process.env.ANTHROPIC_API_KEY ? '✅' : '❌ (set ANTHROPIC_API_KEY in .env)'}`)
})
