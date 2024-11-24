//
//  pushupCountApp.swift
//  pushupCount
//
//  Created by 박재형 on 11/19/24.
//

import SwiftUI

// 앱이 구동될 때 entry point
// UIkit에서 delegate같은 역할을 하는 객체, App.
@main
struct pushupCountApp: App {
    // App 은 body라는 property 가지고 있고, 그 타입은 Scene
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
