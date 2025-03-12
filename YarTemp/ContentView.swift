//
//  ContentView.swift
//  YarTemp
//
//  Created by Iliya Prostakishin on 15.04.2024.
//

import SwiftUI

// MARK: - Termometer image.

struct Termometer: View {
    var temperature: Double
    @Environment(\.colorScheme) var colorScheme

    enum State {
        case medium, high, low
    }
    
    var state: State {
        get {
            switch self.temperature {
            case 10..<27:
                return State.medium
            case 27..<50:
                return State.high
            default:
                return State.low
            }
        }
    }

    var imageName: String {
        get {
            switch self.state {
            case State.medium:
                return "thermometer.medium"
            case State.high:
                return "thermometer.high"
            default:
                return "thermometer.low"
            }

        }
    }
    
    var accessibilityLabel: LocalizedStringKey {
        get {
            switch self.state {
            case State.medium:
                return "thermometer medium"
            case State.high:
                return "thermometer high"
            default:
                return "thermometer low"
            }
        }
    }
    
    var imageColor: Color {
        get {
            switch self.state {
            case State.medium:
                return self.colorScheme == .dark ? .white : .black
            case State.high:
                return .pink
            default:
                return .blue
            }
        }
    }

    init(for t: Double) {
        self.temperature = t
    }
    
    var body: some View {
        Image(self.imageName)
            .resizable()
            .scaledToFit()
            .frame(width: 32, height: 32)
            .foregroundColor(self.imageColor)
            .accessibilityLabel(self.accessibilityLabel)
    }
}

// MARK: - Arrow image.

struct Arrow: View {
    var number: Double
    enum State {
        case up, down
    }
    
    var state: State {
        get {
            return self.number > 0 ? State.up : State.down
        }
    }
    
    static let imageUp: String = "arrowtriangle.up.fill"
    static let imageDown: String = "arrowtriangle.down.fill"

    var imageName: String {
        get {
            switch self.state {
            case State.up:
                return Arrow.imageUp
            default:
                return Arrow.imageDown
            }
        }
    }
    
    var accessibilityLabel: LocalizedStringKey {
        get {
            switch self.state {
            case State.up:
                return "arrow up"
            default:
                return "arrow down"
            }
        }
    }
    
    var color: Color {
        get {
            switch self.state {
            case State.up:
                return Color("ArrowUp")
            default:
                return Color("ArrowDown")
            }
        }
    }

    init(for n: Double) {
        number = n
    }
    
    var body: some View {
        Image(systemName: self.imageName)
            .foregroundColor(self.color)
        .accessibilityLabel(self.accessibilityLabel)
    }
}

// MARK: - Error view

struct ErrorView: View {
    var errorText: String
    private let rect = RoundedRectangle(cornerRadius: 10, style: .continuous)
    var body: some View {
        ZStack {
            rect
                .fill(.pink.opacity(0.1))
                .overlay {
                    rect
                        .stroke(.pink.opacity(0.5))
                }
            VStack(spacing: 5) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .imageScale(.large)
                Text(errorText)
                    .padding(.horizontal, 10)
            }
            .multilineTextAlignment(.center)
            .foregroundColor(.pink)
        }
        .padding(.horizontal, 20)
        .frame(maxWidth: .infinity, maxHeight: 100)
        .accessibilityLabel("error message box")
        .accessibilityValue(errorText)
    }
}

// MARK: - Hint view

struct HintView : View {
    var body: some View {
        Text("\(Image(systemName: "chevron.down")) Pull to refresh", comment: "Refresh hint (iOS)")
        .foregroundColor(.secondary)
    }
}

// MARK: - Refresh button

extension Button {
    @ViewBuilder
    func colorSchemeAdaptiveStyle(_ colorScheme: ColorScheme) -> some View {
        switch colorScheme {
            case .dark:
                self
                    // The .tint is not working without this.
                    .buttonStyle(.borderedProminent)
                    // Make button visible on both dark and light desktops
                    // (by default it's badly visible on semitransparent
                    // background and light-colored desktop).
                    .tint(.primary)
            default:
                self.buttonStyle(.automatic)
        }
    }
}

class Completion: ObservableObject {
    private(set) var inProgress = false

    func callAsFunction(of action: () async -> Void) async {
        guard !inProgress else { return }
        inProgress = true
        await action()
        inProgress = false
    }
}

struct RefreshButton : View {
    var action: () async -> Void
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var completion: Completion

    var body: some View {
        Button(action: {
                    Task {
                        await action()
                   }
                }, label: {
                    Label("Refresh", systemImage: "arrow.clockwise")
                })
        .colorSchemeAdaptiveStyle(colorScheme)
        .disabled(completion.inProgress)
    }
}

struct QuitButton : View {
    var action: () -> Void
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var completion: Completion

    var body: some View {
        Button(action: {
            action()
                }, label: {
                    Label("Quit", systemImage: "xmark")
                })
        .colorSchemeAdaptiveStyle(colorScheme)
    }
}

// MARK: - Main view

struct ContentView: View {
    @EnvironmentObject var model: YarTempViewModel
    @StateObject private var completion = Completion()
    private let rect = RoundedRectangle(cornerRadius: 10, style: .continuous)

    func refresh() async {
        await model.refresh()
    }
    func refresh(by refresher: YarTempViewModel.Refresher) async {
        await model.refresh(by: refresher)
    }
 
    var body: some View {
        #if os(macOS)
        // FIXME: There is important not to keep localizable strings
        // inside #if-endif blocks, because XCode may have troubles
        // with exporting of such strings. As a workaround, enclose
        // them into separate views, like HintView().
        VStack(spacing: 0) {
            ZStack {
                rect
                    .fill(.thinMaterial)
                    .shadow(color: .black.opacity(0.2), radius: 3, x: 0, y: 2)
                    .overlay {
                        rect
                            .stroke(.quaternary)
                    }
                if (completion.inProgress) {
                    ProgressView()
                }
                else {
                    YarTempView(model: model)
                        .environment(\.headerRadius, 10)
                }
            }
            .frame(width: 300, height: 310)
            .padding(11)
            .task {
                await completion {
                    await refresh()
                }
            }
            HStack {
                RefreshButton {
                    await completion {
                        await refresh(by: .user)
                    }
                }
                QuitButton {
                    NSApplication.shared.terminate(nil)
                }
            }
            .padding(.bottom, 11)
        }
        .environmentObject(completion)
        #else
        VStack {
            Text("YarTemp: Temperature in Yaroslavl", comment: "Title on the main screen (iOS)")
            List {
                YarTempView(model: model, withHeader: false)
                    .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/)
                    .task {
                        await refresh()
                    }
                    .overlay(alignment: .center) {
                        if let error = model.error {
                            ZStack {
                                Rectangle()
                                    .fill(Color(.white))
                                ErrorView(errorText: error.localizedDescription)
                            }
                        }
                    }
                }
                .refreshable {
                    await refresh()
                }
                HintView()
                    .padding(.bottom, 11)
        }
        #endif
    }
}

#Preview {
    ContentView().environmentObject(YarTempViewModel())
}

// MARK: - Custom string interpolations for text views
// More about custom string interpolations: http://bit.ly/3VoutrM

extension LocalizedStringKey.StringInterpolation {
    mutating func appendInterpolation(_ value: Measurement<UnitTemperature>) {
        let result = value.formatted(.measurement(
            width: .narrow,
            usage: .weather,
            numberFormatStyle: .number.precision(.significantDigits(2))))
        appendLiteral(result)
    }
}
extension LocalizedStringKey.StringInterpolation {
    mutating func appendInterpolation(_ value: Measurement<UnitPressure>) {
        let result = value.formatted()
        appendLiteral(result)
    }
}
