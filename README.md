<div align="center">
    <br>
    <h1>👨‍💼 Medsenger IOS</h1>
</div>

_iOS/SwiftUI_ mobile application for telemedicine service Medsenger.

## Building

1. Create `Config.swift` file with folowing data:

    ```swift
    struct AppConfig {
        static let iceServers = [
            RTCIceServer(
                urlStrings: ["turn:123.456.789.132:4321"],
                username: "blabla",
                credential: "lolkek"
            ),
            RTCIceServer(urlStrings: [
                "stun:stun.l.google.com:12345"
            ])
        ]
    }
    ```
    
2. Add firebase configuration `GoogleService-Info.plist` file into project

## Codestyle guidelines

Fields order in _SwiftUI_ View:

```Swift
struct ContentView: View {
    // 1. Public constants
    let var name: String
    
    // 2. Public varibles
    let var state: State
    
    // 3. Binding varibles
    @Binding var presentationMode: PresentationMode
    
    // 4. Observed Objects
    @ObservedObject var contract: Contract
    
    // 5. Environment Objects
    @EnvironmentObject private var networkConnectionMonitor: NetworkConnectionMonitor
    
    // 6. State objects
    @StateObject private var settingsViewModel = SettingsViewModel()
    
    // 7. Environment
    @Environment(\.presentationMode) private var presentationMode
    
    // 8. FetchRequest
    @FetchRequest(sortDescriptors: [], animation: .default) private var users: FetchedResults<User>
    
    // 9. App Storage
    @AppStorage(UserDefaults.Keys.userRoleKey) var userRole: UserRole = UserDefaults.userRole
    
    // 10. Focus State
    @FocusState private var isTextFocused
    
    // 11. State
    @State private var showAvatarImage = false
    
    // 12 Private constants
    private let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
    
    // 13. Private varibles
    private var objects = [String]()
    
    // 14. Computed varbles
    var body: some View {
        Text(label)
    }
    
    // 15. methods
    private func label() -> String {
        "Hello World!"
    }
}
```

## 💼 License

Created by Tikhon Petrishchev

Copyright © 2022 OOO Telepat. All rights reserved.
