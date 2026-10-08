//
//  hotprospects_hws_16App.swift
//  hotprospects_hws_16
//
//  Created by Onur Ay on 07.10.26.
//
import SwiftData
import SwiftUI


@main
struct hotprospects_hws_16App: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: Prospect.self)
    }
}
