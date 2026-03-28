import SwiftUI

struct DailyCheckView: View {
    @EnvironmentObject var vm: ConsultationViewModel
    @Environment(\.dismiss) private var dismiss

    private let tealAccent  = Color(red: 0.2,  green: 0.85, blue: 0.6)
    private let orangeAccent = Color(red: 0.9,  green: 0.55, blue: 0.2)

    var body: some View {
        ZStack {
            Color.navyDark.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 16) {
                    progressRingsSection
                    goalsBreakdownSection
                    motivationalBanner
                    aiConsultSection
                }
                .padding(16)
                .padding(.bottom, 40)
            }
        }
        .navigationTitle("Daily Progress")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                if !vm.isCheckingDaily && !vm.dailyConsultation.isEmpty {
                    ShareLink(item: vm.dailyConsultation) {
                        Image(systemName: "square.and.arrow.up")
                            .foregroundColor(tealAccent)
                    }
                }
            }
        }
        .preferredColorScheme(.dark)
    }

    // MARK: - Progress Rings / Summary Cards

    private var progressRingsSection: some View {
        VStack(spacing: 12) {
            // Header
            HStack {
                Text(vm.todayInput.date.isEmpty ? "Today" : vm.todayInput.date)
                    .font(.headline)
                    .foregroundColor(.white)
                Spacer()
                Text("Daily Progress")
                    .font(.caption)
                    .foregroundColor(.init(white: 0.4))
            }
            .padding(.bottom, 4)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                progressCard(
                    icon: "flame.fill",
                    label: "Calories",
                    current: vm.todayInput.totalCalories,
                    goal: vm.dailyGoals.calorieGoal,
                    unit: "kcal",
                    color: orangeAccent
                )
                progressCard(
                    icon: "drop.fill",
                    label: "Water",
                    current: vm.todayInput.waterGlasses,
                    goal: vm.dailyGoals.waterGoal,
                    unit: "glasses",
                    color: tealAccent
                )
                progressCard(
                    icon: "dumbbell.fill",
                    label: "Workout",
                    current: vm.todayInput.workoutMinutes,
                    goal: vm.dailyGoals.workoutGoal,
                    unit: "min",
                    color: Color(red: 0.5, green: 0.4, blue: 0.95)
                )
                progressCard(
                    icon: "shoe.fill",
                    label: "Steps",
                    current: vm.todayInput.stepsCount,
                    goal: vm.dailyGoals.stepsGoal,
                    unit: "steps",
                    color: Color.gold
                )
            }

            // Sleep card (full width)
            sleepCard
        }
        .padding(14)
        .background(Color.navyCard)
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.white.opacity(0.07), lineWidth: 1))
        .cornerRadius(14)
    }

    private func progressCard(
        icon: String,
        label: String,
        current: Int,
        goal: Int,
        unit: String,
        color: Color
    ) -> some View {
        let pct = goal > 0 ? min(Double(current) / Double(goal), 1.0) : 0

        return VStack(spacing: 10) {
            ZStack {
                Circle()
                    .stroke(color.opacity(0.15), lineWidth: 6)
                    .frame(width: 70, height: 70)
                Circle()
                    .trim(from: 0, to: pct)
                    .stroke(color, style: StrokeStyle(lineWidth: 6, lineCap: .round))
                    .frame(width: 70, height: 70)
                    .rotationEffect(.degrees(-90))
                    .animation(.easeOut(duration: 0.6), value: pct)

                VStack(spacing: 1) {
                    Image(systemName: icon)
                        .font(.system(size: 12))
                        .foregroundColor(color)
                    Text("\(Int(pct * 100))%")
                        .font(.caption2.bold())
                        .foregroundColor(.white)
                }
            }

            VStack(spacing: 2) {
                Text(label)
                    .font(.caption2)
                    .foregroundColor(.init(white: 0.5))
                Text("\(current) / \(goal)")
                    .font(.caption.monospacedDigit())
                    .foregroundColor(.white)
                Text(unit)
                    .font(.caption2)
                    .foregroundColor(.init(white: 0.3))
            }
        }
        .padding(10)
        .background(Color.navyDark)
        .cornerRadius(12)
    }

    private var sleepCard: some View {
        let goal = vm.dailyGoals.sleepGoal
        let current = vm.todayInput.sleepHours
        let pct = goal > 0 ? min(current / goal, 1.0) : 0

        return HStack(spacing: 14) {
            ZStack {
                Circle()
                    .stroke(Color(red: 0.3, green: 0.3, blue: 0.8).opacity(0.15), lineWidth: 6)
                    .frame(width: 54, height: 54)
                Circle()
                    .trim(from: 0, to: pct)
                    .stroke(Color(red: 0.5, green: 0.5, blue: 0.95), style: StrokeStyle(lineWidth: 6, lineCap: .round))
                    .frame(width: 54, height: 54)
                    .rotationEffect(.degrees(-90))
                    .animation(.easeOut(duration: 0.6), value: pct)
                Image(systemName: "moon.zzz.fill")
                    .font(.system(size: 16))
                    .foregroundColor(Color(red: 0.5, green: 0.5, blue: 0.95))
            }

            VStack(alignment: .leading, spacing: 2) {
                Text("Sleep")
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(.white)
                HStack(spacing: 4) {
                    Text(current > 0 ? String(format: "%.1f hrs", current) : "Not logged")
                        .font(.caption.monospacedDigit())
                        .foregroundColor(current > 0 ? .white : .init(white: 0.4))
                    Text("/ \(String(format: "%.1f", goal)) hrs goal")
                        .font(.caption2)
                        .foregroundColor(.init(white: 0.35))
                }
            }

            Spacer()

            Text("\(Int(pct * 100))%")
                .font(.title3.bold())
                .foregroundColor(Color(red: 0.5, green: 0.5, blue: 0.95))
        }
        .padding(12)
        .background(Color.navyDark)
        .cornerRadius(12)
    }

    // MARK: - Goals Breakdown

    private var goalsBreakdownSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Goal Breakdown")
                .font(.subheadline.weight(.semibold))
                .foregroundColor(.init(white: 0.6))

            ForEach(goalRows, id: \.label) { row in
                goalRow(row)
            }
        }
        .padding(14)
        .background(Color.navyCard)
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.white.opacity(0.07), lineWidth: 1))
        .cornerRadius(14)
    }

    private struct GoalRow {
        let label: String
        let icon: String
        let current: String
        let goal: String
        let pct: Double
        let color: Color
        let status: String
    }

    private var goalRows: [GoalRow] {
        let goals = vm.dailyGoals
        let input = vm.todayInput
        return [
            GoalRow(
                label: "Calories",
                icon: "flame.fill",
                current: "\(input.totalCalories) kcal",
                goal: "\(goals.calorieGoal) kcal",
                pct: goals.calorieGoal > 0 ? min(Double(input.totalCalories) / Double(goals.calorieGoal), 1.2) : 0,
                color: orangeAccent,
                status: calorieStatus(current: input.totalCalories, goal: goals.calorieGoal)
            ),
            GoalRow(
                label: "Water",
                icon: "drop.fill",
                current: "\(input.waterGlasses) glasses",
                goal: "\(goals.waterGoal) glasses",
                pct: goals.waterGoal > 0 ? min(Double(input.waterGlasses) / Double(goals.waterGoal), 1.0) : 0,
                color: tealAccent,
                status: input.waterGlasses >= goals.waterGoal ? "✅" : "⚡"
            ),
            GoalRow(
                label: "Workout",
                icon: "dumbbell.fill",
                current: "\(input.workoutMinutes) min",
                goal: "\(goals.workoutGoal) min",
                pct: goals.workoutGoal > 0 ? min(Double(input.workoutMinutes) / Double(goals.workoutGoal), 1.0) : 0,
                color: Color(red: 0.5, green: 0.4, blue: 0.95),
                status: input.workoutMinutes >= goals.workoutGoal ? "✅" : "⚡"
            ),
            GoalRow(
                label: "Steps",
                icon: "shoe.fill",
                current: "\(input.stepsCount)",
                goal: "\(goals.stepsGoal)",
                pct: goals.stepsGoal > 0 ? min(Double(input.stepsCount) / Double(goals.stepsGoal), 1.0) : 0,
                color: Color.gold,
                status: input.stepsCount >= goals.stepsGoal ? "✅" : "⚡"
            ),
            GoalRow(
                label: "Sleep",
                icon: "moon.zzz.fill",
                current: input.sleepHours > 0 ? String(format: "%.1f hrs", input.sleepHours) : "—",
                goal: String(format: "%.1f hrs", goals.sleepGoal),
                pct: goals.sleepGoal > 0 ? min(input.sleepHours / goals.sleepGoal, 1.0) : 0,
                color: Color(red: 0.5, green: 0.5, blue: 0.95),
                status: input.sleepHours >= goals.sleepGoal ? "✅" : "⚡"
            ),
        ]
    }

    private func goalRow(_ row: GoalRow) -> some View {
        VStack(spacing: 6) {
            HStack {
                Image(systemName: row.icon)
                    .foregroundColor(row.color)
                    .font(.system(size: 12))
                    .frame(width: 16)
                Text(row.label)
                    .font(.subheadline)
                    .foregroundColor(.white)
                Spacer()
                Text(row.current)
                    .font(.caption.monospacedDigit())
                    .foregroundColor(.init(white: 0.6))
                Text("/ \(row.goal)")
                    .font(.caption2)
                    .foregroundColor(.init(white: 0.35))
                Text(row.status)
                    .font(.caption)
                    .frame(width: 20)
            }

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 3)
                        .fill(row.color.opacity(0.12))
                        .frame(height: 6)
                    RoundedRectangle(cornerRadius: 3)
                        .fill(row.color)
                        .frame(width: geo.size.width * row.pct, height: 6)
                        .animation(.easeOut(duration: 0.5), value: row.pct)
                }
            }
            .frame(height: 6)
        }
    }

    private func calorieStatus(current: Int, goal: Int) -> String {
        guard goal > 0 else { return "⚡" }
        let pct = Double(current) / Double(goal)
        if pct < 0.7  { return "⬇️" }
        if pct <= 1.1 { return "✅" }
        return "⬆️"
    }

    // MARK: - Motivational Banner

    private var motivationalBanner: some View {
        HStack(alignment: .top, spacing: 12) {
            Text(motivationalEmoji)
                .font(.title2)
            VStack(alignment: .leading, spacing: 3) {
                Text("Physician's Take")
                    .font(.caption2.weight(.semibold))
                    .foregroundColor(.init(white: 0.4))
                Text(localMotivationalMessage)
                    .font(.subheadline)
                    .foregroundColor(.init(white: 0.75))
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(14)
        .background(Color.navyCard)
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.gold.opacity(0.2), lineWidth: 1))
        .cornerRadius(14)
    }

    private var motivationalEmoji: String {
        let score = overallScore
        if score >= 80 { return "🏆" }
        if score >= 60 { return "💪" }
        if score >= 40 { return "📈" }
        return "⚡"
    }

    /// 0–100 overall daily score
    private var overallScore: Int {
        let goals  = vm.dailyGoals
        let input  = vm.todayInput
        var points = 0
        var total  = 0

        // Calories: score full points if within ±15% of goal
        if goals.calorieGoal > 0 {
            total += 25
            let pct = Double(input.totalCalories) / Double(goals.calorieGoal)
            if pct >= 0.85 && pct <= 1.15 { points += 25 }
            else if pct >= 0.7 && pct <= 1.3 { points += 12 }
        }

        if goals.waterGoal > 0 {
            total += 25
            points += min(25, Int(25.0 * Double(input.waterGlasses) / Double(goals.waterGoal)))
        }

        if goals.workoutGoal > 0 {
            total += 25
            points += min(25, Int(25.0 * Double(input.workoutMinutes) / Double(goals.workoutGoal)))
        }

        if goals.stepsGoal > 0 {
            total += 25
            points += min(25, Int(25.0 * Double(input.stepsCount) / Double(goals.stepsGoal)))
        }

        return total > 0 ? Int(Double(points) / Double(total) * 100) : 0
    }

    private var localMotivationalMessage: String {
        let goals  = vm.dailyGoals
        let input  = vm.todayInput
        let score  = overallScore

        var msgs: [String] = []

        // Calorie insight
        if goals.calorieGoal > 0 {
            let diff = input.totalCalories - goals.calorieGoal
            if diff > 200 {
                msgs.append("You're \(diff) kcal over your target — adjust dinner or skip evening snacks.")
            } else if input.totalCalories < Int(Double(goals.calorieGoal) * 0.7) && input.totalCalories > 0 {
                msgs.append("Calorie intake is low. Under-eating slows metabolism and impairs recovery.")
            } else if input.totalCalories == 0 {
                msgs.append("No meals logged yet — start tracking to see your calorie balance.")
            }
        }

        // Water insight
        let waterDeficit = goals.waterGoal - input.waterGlasses
        if waterDeficit > 3 {
            msgs.append("You're \(waterDeficit) glasses short of your hydration target. Dehydration impairs cognition and fat metabolism.")
        }

        // Workout insight
        if input.workoutMinutes == 0 {
            msgs.append("No workout logged today. Even 20 minutes of Zone 2 cardio is enough to maintain metabolic health.")
        } else if input.workoutMinutes >= goals.workoutGoal {
            msgs.append("Workout goal achieved. Prioritize 7–8 hours of sleep tonight for optimal recovery.")
        }

        // Sleep insight
        if input.sleepHours > 0 && input.sleepHours < goals.sleepGoal - 1 {
            msgs.append("Last night's sleep was short. Sleep debt suppresses testosterone, elevates cortisol, and increases insulin resistance.")
        }

        // Steps insight
        if input.stepsCount > 0 && input.stepsCount < goals.stepsGoal {
            let remaining = goals.stepsGoal - input.stepsCount
            msgs.append("\(remaining) more steps to hit your daily target — a 15-minute walk will do it.")
        }

        if msgs.isEmpty {
            if score >= 80 {
                return "Outstanding day. All major health vectors are on target. This consistency compounds into exceptional long-term health outcomes."
            } else {
                return "Log your meals, water, and activity above to get a personalized daily assessment."
            }
        }

        return msgs.joined(separator: " ")
    }

    // MARK: - AI Consultation Section

    private var aiConsultSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 10) {
                Rectangle()
                    .fill(tealAccent.opacity(0.3))
                    .frame(height: 1)
                Text("AI CONSULTATION")
                    .font(.caption2.weight(.semibold))
                    .foregroundColor(tealAccent.opacity(0.8))
                    .fixedSize()
                Rectangle()
                    .fill(tealAccent.opacity(0.3))
                    .frame(height: 1)
            }

            if vm.dailyConsultation.isEmpty && !vm.isCheckingDaily {
                // Trigger button
                Button {
                    Task { await vm.generateDailyConsultation() }
                } label: {
                    HStack(spacing: 12) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(tealAccent.opacity(0.12))
                                .frame(width: 44, height: 44)
                            Image(systemName: "stethoscope")
                                .foregroundColor(tealAccent)
                                .font(.system(size: 20))
                        }
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Get AI Daily Consultation")
                                .font(.subheadline.weight(.semibold))
                                .foregroundColor(.white)
                            Text("GPT-4o analyzes your day vs. your health goals")
                                .font(.caption)
                                .foregroundColor(.init(white: 0.45))
                        }
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundColor(tealAccent)
                            .font(.caption.weight(.semibold))
                    }
                    .padding(14)
                    .background(Color.navyCard)
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(tealAccent.opacity(0.35), lineWidth: 1)
                    )
                    .cornerRadius(14)
                }
                .buttonStyle(.plain)

            } else if vm.isCheckingDaily && vm.dailyConsultation.isEmpty {
                HStack(spacing: 14) {
                    ProgressView()
                        .progressViewStyle(.circular)
                        .tint(tealAccent)
                        .scaleEffect(0.9)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Consulting your physician…")
                            .font(.subheadline.weight(.semibold))
                            .foregroundColor(.white)
                        Text("Analyzing your day against personalized goals")
                            .font(.caption)
                            .foregroundColor(.init(white: 0.45))
                    }
                    Spacer()
                }
                .padding(14)
                .background(Color.navyCard)
                .overlay(RoundedRectangle(cornerRadius: 14).stroke(tealAccent.opacity(0.25), lineWidth: 1))
                .cornerRadius(14)

            } else if !vm.dailyConsultation.isEmpty {
                VStack(alignment: .leading, spacing: 0) {
                    MarkdownDocument(content: vm.dailyConsultation, isStreaming: vm.isCheckingDaily)
                        .padding(16)
                }
                .background(Color.navyCard)
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(tealAccent.opacity(0.25), lineWidth: 1)
                )
                .cornerRadius(14)

                if !vm.isCheckingDaily {
                    Button {
                        Task { await vm.generateDailyConsultation() }
                    } label: {
                        Label("Refresh Consultation", systemImage: "arrow.clockwise")
                            .font(.caption.weight(.semibold))
                            .foregroundColor(tealAccent)
                    }
                    .padding(.top, 4)
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        DailyCheckView()
            .environmentObject({
                let vm = ConsultationViewModel()
                vm.todayInput.breakfast  = MealEntry(description: "Oats with banana", calories: "350")
                vm.todayInput.lunch      = MealEntry(description: "Dal rice", calories: "520")
                vm.todayInput.waterGlasses   = 5
                vm.todayInput.workoutMinutes = 25
                vm.todayInput.stepsCount     = 6200
                vm.todayInput.sleepHours     = 6.5
                return vm
            }())
    }
}
