import SwiftUI
import PhotosUI

struct TodayInputView: View {
    @EnvironmentObject var vm: ConsultationViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var showDailyCheck = false

    // Photo picker state per meal slot
    @State private var breakfastPhoto: PhotosPickerItem?
    @State private var lunchPhoto:     PhotosPickerItem?
    @State private var dinnerPhoto:    PhotosPickerItem?
    @State private var snacksPhoto:    PhotosPickerItem?

    // Analyzing state per meal slot
    @State private var analyzingBreakfast = false
    @State private var analyzingLunch     = false
    @State private var analyzingDinner    = false
    @State private var analyzingSnacks    = false

    @State private var photoError: String?

    private let tealAccent = Color(red: 0.2, green: 0.85, blue: 0.6)

    var body: some View {
        NavigationStack {
            ZStack {
                Color.navyDark.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 16) {
                        dateHeader
                        mealsSection
                        waterSection
                        fitnessSection
                        if let err = photoError { errorBanner(err) }
                        consultButton
                    }
                    .padding(16)
                    .padding(.bottom, 40)
                }
            }
            .navigationTitle("Today's Input")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                        .foregroundColor(tealAccent)
                        .fontWeight(.semibold)
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Reset Today") {
                        vm.todayInput = TodayInput()
                        vm.dailyConsultation = ""
                    }
                    .foregroundColor(.init(white: 0.4))
                    .font(.subheadline)
                }
            }
            // Photo change handlers
            .onChange(of: breakfastPhoto) { item in
                guard let item else { return }
                Task { await analyzePhoto(item: item, slot: .breakfast); breakfastPhoto = nil }
            }
            .onChange(of: lunchPhoto) { item in
                guard let item else { return }
                Task { await analyzePhoto(item: item, slot: .lunch); lunchPhoto = nil }
            }
            .onChange(of: dinnerPhoto) { item in
                guard let item else { return }
                Task { await analyzePhoto(item: item, slot: .dinner); dinnerPhoto = nil }
            }
            .onChange(of: snacksPhoto) { item in
                guard let item else { return }
                Task { await analyzePhoto(item: item, slot: .snacks); snacksPhoto = nil }
            }
            .navigationDestination(isPresented: $showDailyCheck) {
                DailyCheckView()
            }
        }
        .preferredColorScheme(.dark)
    }

    // MARK: - Date Header

    private var dateHeader: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(formattedDate)
                    .font(.title3.bold())
                    .foregroundColor(.white)
                Text("Log your meals, water & fitness for today")
                    .font(.caption)
                    .foregroundColor(.init(white: 0.45))
            }
            Spacer()
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(tealAccent.opacity(0.15))
                    .frame(width: 44, height: 44)
                Image(systemName: "calendar")
                    .foregroundColor(tealAccent)
                    .font(.system(size: 18))
            }
        }
        .padding(14)
        .background(Color.navyCard)
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(tealAccent.opacity(0.25), lineWidth: 1))
        .cornerRadius(14)
        .onAppear {
            // Auto-set date when opening
            if vm.todayInput.date.isEmpty {
                vm.todayInput.date = formattedDate
            }
        }
    }

    private var formattedDate: String {
        let f = DateFormatter()
        f.dateFormat = "EEEE, MMM d yyyy"
        return f.string(from: Date())
    }

    // MARK: - Meals Section

    private var mealsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader(icon: "🍽️", title: "Meals")

            mealCard(
                slot: .breakfast,
                title: "Breakfast",
                icon: "sun.and.horizon.fill",
                isAnalyzing: analyzingBreakfast,
                entry: $vm.todayInput.breakfast,
                photoItem: $breakfastPhoto
            )
            mealCard(
                slot: .lunch,
                title: "Lunch",
                icon: "sun.max.fill",
                isAnalyzing: analyzingLunch,
                entry: $vm.todayInput.lunch,
                photoItem: $lunchPhoto
            )
            mealCard(
                slot: .dinner,
                title: "Dinner",
                icon: "moon.stars.fill",
                isAnalyzing: analyzingDinner,
                entry: $vm.todayInput.dinner,
                photoItem: $dinnerPhoto
            )
            mealCard(
                slot: .snacks,
                title: "Snacks",
                icon: "leaf.fill",
                isAnalyzing: analyzingSnacks,
                entry: $vm.todayInput.snacks,
                photoItem: $snacksPhoto
            )

            // Calorie summary
            if vm.todayInput.totalCalories > 0 {
                HStack {
                    Text("Total today:")
                        .font(.caption)
                        .foregroundColor(.init(white: 0.45))
                    Text("\(vm.todayInput.totalCalories) kcal")
                        .font(.caption.weight(.semibold))
                        .foregroundColor(tealAccent)
                    Text("/ Goal: \(vm.dailyGoals.calorieGoal) kcal")
                        .font(.caption2)
                        .foregroundColor(.init(white: 0.35))
                }
                .padding(.horizontal, 4)
            }
        }
    }

    private func mealCard(
        slot: MealSlot,
        title: String,
        icon: String,
        isAnalyzing: Bool,
        entry: Binding<MealEntry>,
        photoItem: Binding<PhotosPickerItem?>
    ) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .foregroundColor(tealAccent)
                    .font(.system(size: 14))
                Text(title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(.white)
                Spacer()
                if !entry.calories.wrappedValue.isEmpty {
                    Text("\(entry.calories.wrappedValue) kcal")
                        .font(.caption2.weight(.semibold))
                        .foregroundColor(tealAccent)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(tealAccent.opacity(0.12))
                        .cornerRadius(6)
                }
            }

            // Description field
            TextField("What did you eat? (e.g. 2 eggs, toast, coffee)", text: entry.description)
                .font(.subheadline)
                .foregroundColor(.white)
                .padding(.horizontal, 10)
                .padding(.vertical, 8)
                .background(Color.navyDark)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
                .cornerRadius(8)

            HStack(spacing: 10) {
                // Calories field
                HStack(spacing: 6) {
                    Image(systemName: "flame.fill")
                        .foregroundColor(.orange.opacity(0.7))
                        .font(.system(size: 12))
                    TextField("kcal", text: entry.calories)
                        .keyboardType(.numberPad)
                        .font(.subheadline.monospacedDigit())
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 8)
                .background(Color.navyDark)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(!entry.calories.wrappedValue.isEmpty ? tealAccent.opacity(0.4) : Color.white.opacity(0.1), lineWidth: 1)
                )
                .cornerRadius(8)

                // Photo upload button
                if isAnalyzing {
                    HStack(spacing: 6) {
                        ProgressView()
                            .progressViewStyle(.circular)
                            .tint(tealAccent)
                            .scaleEffect(0.7)
                        Text("Analyzing…")
                            .font(.caption)
                            .foregroundColor(tealAccent)
                    }
                    .frame(height: 36)
                } else {
                    PhotosPicker(selection: photoItem, matching: .images, photoLibrary: .shared()) {
                        HStack(spacing: 5) {
                            Image(systemName: "camera.fill")
                                .font(.system(size: 12))
                            Text("Photo")
                                .font(.caption.weight(.semibold))
                        }
                        .foregroundColor(tealAccent)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 8)
                        .background(tealAccent.opacity(0.12))
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(tealAccent.opacity(0.3), lineWidth: 1)
                        )
                        .cornerRadius(8)
                    }
                }
            }
        }
        .padding(12)
        .background(Color.navyCard)
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.white.opacity(0.07), lineWidth: 1))
        .cornerRadius(12)
    }

    // MARK: - Water Section

    private var waterSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader(icon: "💧", title: "Water Intake")

            HStack(spacing: 20) {
                // Minus button
                Button {
                    if vm.todayInput.waterGlasses > 0 {
                        vm.todayInput.waterGlasses -= 1
                    }
                } label: {
                    Image(systemName: "minus.circle.fill")
                        .font(.system(size: 32))
                        .foregroundColor(vm.todayInput.waterGlasses > 0 ? tealAccent : .init(white: 0.25))
                }
                .buttonStyle(.plain)

                // Counter display
                VStack(spacing: 2) {
                    Text("\(vm.todayInput.waterGlasses)")
                        .font(.system(size: 44, weight: .bold, design: .monospaced))
                        .foregroundColor(.white)
                    Text("of \(vm.dailyGoals.waterGoal) glasses")
                        .font(.caption)
                        .foregroundColor(.init(white: 0.4))
                }
                .frame(maxWidth: .infinity)

                // Plus button
                Button {
                    vm.todayInput.waterGlasses += 1
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 32))
                        .foregroundColor(tealAccent)
                }
                .buttonStyle(.plain)
            }
            .padding(16)
            .background(Color.navyCard)
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(tealAccent.opacity(0.2), lineWidth: 1))
            .cornerRadius(12)

            // Glass icons
            let target = vm.dailyGoals.waterGoal
            let filled = vm.todayInput.waterGlasses
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: min(target, 8)), spacing: 6) {
                ForEach(0..<target, id: \.self) { i in
                    Image(systemName: i < filled ? "drop.fill" : "drop")
                        .font(.system(size: 18))
                        .foregroundColor(i < filled ? tealAccent : .init(white: 0.2))
                }
            }
        }
        .padding(14)
        .background(Color.navyCard)
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(tealAccent.opacity(0.2), lineWidth: 1))
        .cornerRadius(14)
    }

    // MARK: - Fitness Section

    private var fitnessSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader(icon: "💪", title: "Fitness & Recovery")

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                fitnessField(
                    label: "Workout",
                    unit: "min",
                    icon: "dumbbell.fill",
                    goal: "\(vm.dailyGoals.workoutGoal) min goal",
                    value: Binding(
                        get: { vm.todayInput.workoutMinutes > 0 ? "\(vm.todayInput.workoutMinutes)" : "" },
                        set: { vm.todayInput.workoutMinutes = Int($0) ?? 0 }
                    )
                )
                fitnessField(
                    label: "Walking",
                    unit: "min",
                    icon: "figure.walk",
                    goal: "bonus activity",
                    value: Binding(
                        get: { vm.todayInput.walkingMinutes > 0 ? "\(vm.todayInput.walkingMinutes)" : "" },
                        set: { vm.todayInput.walkingMinutes = Int($0) ?? 0 }
                    )
                )
                fitnessField(
                    label: "Steps",
                    unit: "steps",
                    icon: "shoe.fill",
                    goal: "\(vm.dailyGoals.stepsGoal) goal",
                    value: Binding(
                        get: { vm.todayInput.stepsCount > 0 ? "\(vm.todayInput.stepsCount)" : "" },
                        set: { vm.todayInput.stepsCount = Int($0) ?? 0 }
                    )
                )
                fitnessField(
                    label: "Sleep",
                    unit: "hrs",
                    icon: "moon.zzz.fill",
                    goal: "\(Int(vm.dailyGoals.sleepGoal))+ hrs goal",
                    value: Binding(
                        get: { vm.todayInput.sleepHours > 0 ? String(format: "%.1f", vm.todayInput.sleepHours) : "" },
                        set: { vm.todayInput.sleepHours = Double($0) ?? 0 }
                    )
                )
            }
        }
        .padding(14)
        .background(Color.navyCard)
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color(red: 0.9, green: 0.4, blue: 0.2).opacity(0.25), lineWidth: 1))
        .cornerRadius(14)
    }

    private func fitnessField(
        label: String,
        unit: String,
        icon: String,
        goal: String,
        value: Binding<String>
    ) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .foregroundColor(Color(red: 0.9, green: 0.55, blue: 0.2))
                    .font(.system(size: 11))
                Text(label)
                    .font(.caption2)
                    .foregroundColor(.init(white: 0.5))
                Spacer()
                Text(unit)
                    .font(.caption2)
                    .foregroundColor(.init(white: 0.3))
            }
            TextField("0", text: value)
                .keyboardType(.decimalPad)
                .font(.subheadline.monospacedDigit())
                .foregroundColor(.white)
                .padding(.horizontal, 10)
                .padding(.vertical, 8)
                .background(Color.navyDark)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(!value.wrappedValue.isEmpty
                                ? Color(red: 0.9, green: 0.55, blue: 0.2).opacity(0.4)
                                : Color.white.opacity(0.1), lineWidth: 1)
                )
                .cornerRadius(8)
            Text(goal)
                .font(.caption2)
                .foregroundColor(.init(white: 0.3))
        }
    }

    // MARK: - Consult Button

    private var consultButton: some View {
        Button {
            vm.todayInput.date = formattedDate
            showDailyCheck = true
        } label: {
            HStack(spacing: 10) {
                Image(systemName: "stethoscope")
                    .font(.system(size: 18))
                Text("View Daily Progress & Consult")
                    .font(.headline)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                LinearGradient(
                    colors: [Color(red: 0.1, green: 0.6, blue: 0.45), tealAccent],
                    startPoint: .leading, endPoint: .trailing
                )
            )
            .foregroundColor(.black.opacity(0.85))
            .cornerRadius(14)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Section Header

    private func sectionHeader(icon: String, title: String) -> some View {
        HStack(spacing: 6) {
            Text(icon)
            Text(title)
                .font(.subheadline.weight(.semibold))
                .foregroundColor(tealAccent)
        }
    }

    // MARK: - Error Banner

    private func errorBanner(_ message: String) -> some View {
        HStack(spacing: 10) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(.red)
            Text(message)
                .font(.caption)
                .foregroundColor(.init(white: 0.6))
            Spacer()
            Button { photoError = nil } label: {
                Image(systemName: "xmark")
                    .foregroundColor(.init(white: 0.4))
                    .font(.caption)
            }
        }
        .padding(12)
        .background(Color.red.opacity(0.1))
        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.red.opacity(0.3), lineWidth: 1))
        .cornerRadius(10)
    }

    // MARK: - Photo Analysis

    private enum MealSlot { case breakfast, lunch, dinner, snacks }

    private func analyzePhoto(item: PhotosPickerItem, slot: MealSlot) async {
        setAnalyzing(slot, true)
        defer { setAnalyzing(slot, false) }

        guard let data  = try? await item.loadTransferable(type: Data.self),
              let image = UIImage(data: data) else {
            photoError = "Could not load the selected photo."
            return
        }

        let description: String
        switch slot {
        case .breakfast: description = vm.todayInput.breakfast.description
        case .lunch:     description = vm.todayInput.lunch.description
        case .dinner:    description = vm.todayInput.dinner.description
        case .snacks:    description = vm.todayInput.snacks.description
        }

        do {
            let calories = try await OpenAIService.analyzeFood(image: image, description: description)
            await MainActor.run {
                switch slot {
                case .breakfast: vm.todayInput.breakfast.calories = calories
                case .lunch:     vm.todayInput.lunch.calories     = calories
                case .dinner:    vm.todayInput.dinner.calories    = calories
                case .snacks:    vm.todayInput.snacks.calories    = calories
                }
            }
        } catch {
            photoError = error.localizedDescription
        }
    }

    private func setAnalyzing(_ slot: MealSlot, _ value: Bool) {
        switch slot {
        case .breakfast: analyzingBreakfast = value
        case .lunch:     analyzingLunch     = value
        case .dinner:    analyzingDinner    = value
        case .snacks:    analyzingSnacks    = value
        }
    }
}

#Preview {
    TodayInputView()
        .environmentObject(ConsultationViewModel())
}
