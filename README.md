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

## 💼 License

Created by Tikhon Petrishchev

Copyright © 2022 OOO Telepat. All rights reserved.
