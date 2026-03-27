import SwiftUI

@main
struct MyDoctorApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(ConsultationViewModel())
        }
    }
}
