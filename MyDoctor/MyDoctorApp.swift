import SwiftUI

@main
struct MyDoctorApp: App {
    @StateObject private var vm = ConsultationViewModel()
    @Environment(\.scenePhase) private var scenePhase

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(vm)
        }
        // Flush any debounced save the moment the app moves to the background,
        // so data is never lost even if iOS terminates the process immediately.
        .onChange(of: scenePhase) { phase in
            if phase == .background || phase == .inactive {
                vm.saveImmediately()
            }
        }
    }
}
