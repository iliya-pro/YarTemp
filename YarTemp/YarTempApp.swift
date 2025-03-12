//
//  YarTempApp.swift
//  YarTemp
//
//  Created by Iliya Prostakishin on 15.04.2024.
//

import SwiftUI
import BackgroundTasks
//import ArgumentParser

//struct AppArguments: ParsableArguments {
//    @Option(help: "Offline data string (for testing, when Internet connection is unavailable).")
//    var offline: String?
//}

@main
struct YarTempApp: App {
    @StateObject var model = YarTempViewModel()
        
    var body: some Scene {
        #if os(macOS)
        MenuBarExtra {
            ContentView()
                .environmentObject(model)
        } label: {
            Label("YarTemp", systemImage: "thermometer.medium")
        }
        .menuBarExtraStyle(.window)
        #else
        WindowGroup {
            ContentView()
                .environmentObject(model)
                //.onAppear() {
                //    if let args = try? AppArguments.parse() {
                //        model.commandLineInput = args.offline
                //        model.commandLineInput?.removeAll(where: {$0 == "\""})
                //    }
                //}
        }
        #endif
    }
}
