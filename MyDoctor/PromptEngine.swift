import Foundation

enum PromptEngine {

    // MARK: - System Prompt (Main Consultation)

    static func systemPrompt(mode: ConsultationMode) -> String {
        let base = """
        You are "The Sovereign Physician," the world's foremost expert in concierge medicine and peak human performance. You hold mastery across Cardiology, Internal Medicine, Endocrinology, Dermatology, Orthopedics, and Longevity Medicine. You are the private physician to the world's elite — hedge-fund founders, Olympic athletes, and heads of state. Your mandate is singular: achieve Peak Human Performance. "Normal" is not acceptable. Only "Optimal" matters.

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
        • Maintain a direct, authoritative, high-status tone. You prescribe; you do not suggest.
        """

        switch mode {
        case .standard:
            return base

        case .longevity:
            return base + """


        LONGEVITY SCIENTIST MODE ACTIVATED:
        Emphasize molecular mechanisms throughout: mTOR/AMPK signaling balance, NAD+/SIRT1 axis, mitochondrial biogenesis via PGC-1α, cellular senescence and senolytics (Quercetin, Dasatinib), telomere attrition rates, autophagy induction via fasting windows. Reference Bryan Johnson's Blueprint protocol, Valter Longo's Fasting-Mimicking Diet research, Peter Attia's Zone 2 and VO2max protocols, and David Sinclair's NAD+ work where clinically relevant. For each recommendation, explain the molecular pathway it targets.
        """

        case .toughlove:
            return base + """


        TOUGH LOVE COACH MODE ACTIVATED:
        This patient has a history of inconsistency and self-sabotage. Be brutally direct. Do not coddle. Point out exactly what behaviors are silently destroying their health. Use language like: "Every time you eat X, here is the specific biological damage occurring." Name the destructive habits plainly. Channel the energy of a world-class performance coach who has zero tolerance for excuses. No soft language. No "you might consider." Say "Stop. Now. Permanently." where appropriate.
        """
        }
    }

    // MARK: - User Message (Main Consultation)

    static func userMessage(patientData: PatientData, labValues: [String: String]) -> String {
        let labLines = labValues
            .filter { !$0.value.isEmpty }
            .map { "• \($0.key): \($0.value)" }
            .sorted()
            .joined(separator: "\n")

        return """
        PATIENT CONSULTATION FILE
        ═══════════════════════════════════════

        PATIENT PROFILE
        Name: \(patientData.name.isEmpty ? "Anonymous" : patientData.name)
        Age: \(patientData.age.isEmpty ? "Not provided" : patientData.age) years
        Gender: \(patientData.gender.isEmpty ? "Not specified" : patientData.gender)
        Region / Dietary Background: \(patientData.region.isEmpty ? "Not specified" : patientData.region)
        Height: \(patientData.height.isEmpty ? "Not provided" : patientData.height + " cm")
        Weight: \(patientData.weight.isEmpty ? "Not provided" : patientData.weight + " kg")
        BMI: \(patientData.bmi)

        CHIEF COMPLAINTS & GOALS
        \(patientData.chiefComplaints.isEmpty ? "Not specified" : patientData.chiefComplaints)

        MEDICAL HISTORY
        Active Conditions: \(patientData.conditions.isEmpty ? "None reported" : patientData.conditions.joined(separator: ", "))
        Current Medications: \(patientData.medications.isEmpty ? "None reported" : patientData.medications)
        Allergies: \(patientData.allergies.isEmpty ? "None reported" : patientData.allergies)
        Family History: \(patientData.familyHistory.isEmpty ? "Not provided" : patientData.familyHistory)

        LIFESTYLE FACTORS
        Smoking: \(patientData.smoking.isEmpty ? "Not specified" : patientData.smoking)
        Alcohol: \(patientData.alcohol.isEmpty ? "Not specified" : patientData.alcohol)
        Sleep: \(patientData.sleepHours.isEmpty ? "Not specified" : patientData.sleepHours + " hours/night")
        Activity Level: \(patientData.activityLevel.isEmpty ? "Not specified" : patientData.activityLevel)

        LABORATORY RESULTS
        \(labLines.isEmpty ? "No lab values provided" : labLines)

        ═══════════════════════════════════════
        Perform a complete Sovereign Physician consultation on this patient. Apply your optimal-range framework and regional dietary intelligence. Be comprehensive, specific, and prescriptive.
        """
    }

    // MARK: - Re-consultation

    static func reconsultationMessage(
        patientData: PatientData,
        labValues: [String: String],
        previousReport: String
    ) -> String {
        let labLines = labValues
            .filter { !$0.value.isEmpty }
            .map { "• \($0.key): \($0.value)" }
            .sorted()
            .joined(separator: "\n")

        return """
        RE-CONSULTATION REQUEST
        ═══════════════════════════════════════

        PATIENT: \(patientData.name.isEmpty ? "Anonymous" : patientData.name), \(patientData.age) yrs, \(patientData.gender)
        Region: \(patientData.region.isEmpty ? "Not specified" : patientData.region)

        CURRENT LABS
        \(labLines.isEmpty ? "No lab values provided" : labLines)

        CONDITIONS: \(patientData.conditions.isEmpty ? "None" : patientData.conditions.joined(separator: ", "))

        PREVIOUS BLUEPRINT SUMMARY
        \(String(previousReport.prefix(1500)))

        ═══════════════════════════════════════
        This is a follow-up re-consultation. Review the previous blueprint and provide:
        1. An updated assessment of what has likely changed or needs re-prioritization.
        2. New or refined action items the patient should focus on NOW.
        3. Any protocol adjustments based on the existing data.
        Be direct and specific. Do not repeat the full biomarker breakdown — focus on updated guidance and next steps.
        Use these section headers:

        ## 🔄 Re-consultation Assessment

        ## 🎯 Updated Priority Actions

        ## 📈 Protocol Refinements

        ## ⚠️ Medical Disclaimer
        """
    }

    // MARK: - Meal & Fitness Plan System Prompt

    static func mealFitnessSystemPrompt() -> String {
        return """
        You are "The Sovereign Physician," an elite concierge medicine AI specializing in evidence-based, personalized nutrition and fitness programming. You integrate the latest research in sports science, metabolic nutrition, and longevity medicine to create precise, actionable plans.

        Your meal plans are:
        • Culturally adapted to the patient's regional dietary background
        • Calibrated to the patient's biomarkers and health conditions
        • Based on optimal macronutrient ratios for their specific metabolic profile
        • Structured with specific meal timings, portions, and food choices

        Your fitness plans include both GYM and HOME variants. They are:
        • Periodized (progressive overload)
        • Adapted to the patient's activity level and health conditions
        • Specific about sets, reps, duration, and rest periods
        • Rooted in evidence: Zone 2 cardio for metabolic health, resistance training for hormonal optimization, HIIT for VO2max

        Maintain a direct, authoritative tone. Be specific — name actual foods, exercises, and quantities.
        """
    }

    // MARK: - Meal & Fitness Plan Message

    static func mealFitnessMessage(
        patientData: PatientData,
        labValues: [String: String],
        report: String
    ) -> String {
        let labLines = labValues
            .filter { !$0.value.isEmpty }
            .map { "• \($0.key): \($0.value)" }
            .sorted()
            .joined(separator: "\n")

        return """
        MEAL & FITNESS PLAN REQUEST
        ═══════════════════════════════════════

        PATIENT PROFILE
        Name: \(patientData.name.isEmpty ? "Anonymous" : patientData.name)
        Age: \(patientData.age.isEmpty ? "Not provided" : patientData.age) years
        Gender: \(patientData.gender.isEmpty ? "Not specified" : patientData.gender)
        Region / Dietary Background: \(patientData.region.isEmpty ? "Not specified" : patientData.region)
        Height: \(patientData.height.isEmpty ? "Not provided" : patientData.height + " cm")
        Weight: \(patientData.weight.isEmpty ? "Not provided" : patientData.weight + " kg")
        BMI: \(patientData.bmi)
        Active Conditions: \(patientData.conditions.isEmpty ? "None" : patientData.conditions.joined(separator: ", "))
        Activity Level: \(patientData.activityLevel.isEmpty ? "Not specified" : patientData.activityLevel)
        Sleep: \(patientData.sleepHours.isEmpty ? "Not specified" : patientData.sleepHours + " hrs/night")

        KEY BIOMARKERS
        \(labLines.isEmpty ? "None provided" : labLines)

        HEALTH BLUEPRINT SUMMARY (for context)
        \(report.isEmpty ? "Not yet generated" : String(report.prefix(1000)))

        ═══════════════════════════════════════
        Create a complete, personalized 7-day Meal & Fitness Plan. Use EXACTLY these section headers:

        ## 🍽️ Meal Plan Strategy

        ## 📅 7-Day Meal Plan

        ## 🏋️ Gym Workout Plan (4 days/week)

        ## 🏠 Home Workout Plan (4 days/week)

        ## 💤 Recovery & Sleep Protocol

        ## 📊 Key Nutrition Targets

        For the meal plan: include specific foods, quantities (grams/cups), meal timings, and calorie estimates per meal. Adapt culturally to their region. For workouts: include exercise name, sets × reps/duration, rest periods, and the physiological rationale.
        """
    }

    // MARK: - Daily Consultation System Prompt

    static func dailyConsultationSystemPrompt() -> String {
        return """
        You are "The Sovereign Physician," an elite AI health coach providing daily accountability and guidance. Your role is to analyze the patient's daily food, hydration, fitness, and sleep data against their personalized goals and provide a concise, actionable daily consultation.

        Be direct and motivating. Acknowledge wins specifically. Call out shortfalls without being harsh. Give one or two precise corrective actions for tomorrow. Keep the response focused and practical — this is a daily check-in, not a full consultation.
        """
    }

    // MARK: - Daily Consultation Message

    static func dailyConsultationMessage(
        todayInput: TodayInput,
        dailyGoals: DailyGoals,
        patientData: PatientData
    ) -> String {
        let meals = [
            ("Breakfast", todayInput.breakfast),
            ("Lunch",     todayInput.lunch),
            ("Dinner",    todayInput.dinner),
            ("Snacks",    todayInput.snacks),
        ]
        let mealLines = meals
            .filter { !$0.1.description.isEmpty || !$0.1.calories.isEmpty }
            .map { "• \($0.0): \($0.1.description.isEmpty ? "(no description)" : $0.1.description) — \($0.1.calories.isEmpty ? "?" : $0.1.calories) kcal" }
            .joined(separator: "\n")

        let calPercent = dailyGoals.calorieGoal > 0
            ? Int(Double(todayInput.totalCalories) / Double(dailyGoals.calorieGoal) * 100)
            : 0
        let waterPercent = dailyGoals.waterGoal > 0
            ? Int(Double(todayInput.waterGlasses) / Double(dailyGoals.waterGoal) * 100)
            : 0

        return """
        DAILY CHECK-IN — \(todayInput.date.isEmpty ? "Today" : todayInput.date)
        ═══════════════════════════════════════

        PATIENT: \(patientData.name.isEmpty ? "Patient" : patientData.name)
        Conditions: \(patientData.conditions.isEmpty ? "None" : patientData.conditions.joined(separator: ", "))

        TODAY'S NUTRITION
        \(mealLines.isEmpty ? "No meals logged" : mealLines)
        Total Calories: \(todayInput.totalCalories) kcal / Goal: \(dailyGoals.calorieGoal) kcal (\(calPercent)% of goal)

        HYDRATION
        Water: \(todayInput.waterGlasses) glasses / Goal: \(dailyGoals.waterGoal) glasses (\(waterPercent)%)

        FITNESS
        Workout: \(todayInput.workoutMinutes) min / Goal: \(dailyGoals.workoutGoal) min
        Walking: \(todayInput.walkingMinutes) min
        Steps: \(todayInput.stepsCount) / Goal: \(dailyGoals.stepsGoal)
        Sleep last night: \(todayInput.sleepHours > 0 ? String(format: "%.1f", todayInput.sleepHours) : "not logged") hrs / Goal: \(dailyGoals.sleepGoal) hrs

        ═══════════════════════════════════════
        Provide a concise daily consultation. Use these section headers:

        ## 📊 Today's Score

        ## ✅ What You Did Right

        ## ⚡ What Needs Fixing Tomorrow

        ## 💬 Physician's Note
        """
    }
}
