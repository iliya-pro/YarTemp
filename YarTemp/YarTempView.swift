//
//  YarTempView.swift
//  YarTemp
//
//  Created by Iliya Prostakishin on 16.04.2024.
//

import SwiftUI

// MARK: - Header

private struct HeaderRadiusKey: EnvironmentKey {
    static let defaultValue: CGFloat = 10
}
extension EnvironmentValues {
    var headerRadius: CGFloat {
        get { self[HeaderRadiusKey.self] }
        set { self[HeaderRadiusKey.self] = newValue }
    }
}

struct Header: View {
    @Environment(\.headerRadius) var headerRadius
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                Text("YarTemp")
                    .textCase(.uppercase)
                    .font(.caption)
                    .foregroundColor(Color("HeaderText"))
                    .padding(.vertical, 3)
                    .padding(.horizontal, 15)
                    .background(UnevenRoundedRectangle(cornerRadii: .init(
                        topLeading: 0,
                        bottomLeading: headerRadius,
                        bottomTrailing: 0,
                        topTrailing: headerRadius)).fill(Color("HeaderBackground")))
            }
            Spacer()
        }
    }
}


// MARK: - Divider

struct GradientDivider: View {
    var gradient = Gradient(
        colors: [
            .clear,
            Color(.lightGray)
        ]
    )
    var body: some View {
        GeometryReader { geometry in
            Path { path in
                path.move(to: .zero)
                path.addLine(to: CGPoint(x: geometry.size.width / 2, y: 0))
            }
            .stroke(
                LinearGradient(
                    gradient: gradient,
                    startPoint: .leading,
                    endPoint: .trailing )
            )
            Path { path in
                path.move(to: CGPoint(x: geometry.size.width / 2, y: 0))
                path.addLine(to: CGPoint(x: geometry.size.width, y: 0))
                
            }
            .stroke(
                LinearGradient(
                    gradient: gradient,
                    startPoint: .trailing,
                    endPoint: .leading )
            )
        }
        .frame(height: 1)
    }
}

// MARK: - Temperature info

typealias Temperature = Measurement<UnitTemperature>
typealias Pressure = Measurement<UnitPressure>

enum MeasurementData: Hashable {
    case temperature(title: String, value: Temperature, hourly: Bool = false)
    case pressure(title: String, value: Pressure, hourly: Bool = false)
}

struct YarTempView: View {
    var temperature = Temperature(value: 0, unit: .celsius)
    var withHeader = true
    var rows: [MeasurementData] = []

    @available(iOSApplicationExtension 15.0, macOSApplicationExtension 13.0, *)
    init(temperature: Temperature,
         temperatureChange: Temperature,
         temperatureDayMin: Temperature,
         temperatureDayMax: Temperature,
         temperatureDayAverage: Temperature,
         temperatureDayLastYear: Temperature,
         pressure: Pressure,
         pressureChange: Pressure
    ) {
        self.temperature = temperature
        self.rows = [
            .temperature(title: String(localized: "Temp. change", comment: "Temperature change caption in a grid"), value: temperatureChange, hourly: true),
            .temperature(title: String(localized: "Day low", comment: "Day low temperature caption in a grid"), value: temperatureDayMin),
            .temperature(title: String(localized: "Day high", comment: "Day high temperature caption in a grid"), value: temperatureDayMax),
            .temperature(title: String(localized: "Day average", comment: "Day average temperature caption in a grid"), value: temperatureDayAverage),
            .temperature(title: String(localized: "Last year was", comment: "Last year temperature caption in a grid"), value: temperatureDayLastYear),
            .pressure(title: String(localized: "Pressure", comment: "Pressure caption in a grid"), value: pressure),
            .pressure(title: String(localized: "Pressure change", comment: "Pressure change caption in a grid"), value: pressureChange, hourly: true)
        ]
    }
    @available(iOS 15.0, macOS 13.0, *)
    init(model: YarTempViewModel, withHeader: Bool = true) {
        self.temperature = model.temperature
        self.withHeader = withHeader
        self.rows = [
            .temperature(title: String(localized: "Temp. change", comment: "Temperature change caption in a grid"), value: model.temperatureChange, hourly: true),
            .temperature(title: String(localized: "Day low", comment: "Day low temperature caption in a grid"), value: model.temperatureDayMin),
            .temperature(title: String(localized: "Day high", comment: "Day high temperature caption in a grid"), value: model.temperatureDayMax),
            .temperature(title: String(localized: "Day average", comment: "Day average temperature caption in a grid"), value: model.temperatureDayAverage),
            .temperature(title: String(localized: "Last year was", comment: "Last year temperature caption in a grid"), value: model.temperatureDayLastYear),
            .pressure(title: String(localized: "Pressure", comment: "Pressure caption in a grid"), value: model.pressure),
            .pressure(title: String(localized: "Pressure change", comment: "Pressure change caption in a grid"), value: model.pressureChange, hourly: true)
        ]
    }
    var body: some View {
        ZStack {
            if self.withHeader {
                Header()
            }
            VStack {
                HStack {
                    Termometer(for: temperature.value)
                    Text("\(temperature)")
                        .font(.largeTitle)
                        .accessibilityLabel("temperature")
                        .accessibilityValue("\(temperature)")
                }
                .padding()
                if #available(iOS 16.0, macOS 13.0, *) {
                    Grid(alignment: .topLeading) {
                        ForEach(rows, id: \.self) { row in
                            GridRow(alignment: .firstTextBaseline) {
                                switch(row) {
                                case .temperature(let title, let value, let hourly):
                                    Text(title)
                                        .foregroundColor(.secondary)
                                        .gridColumnAlignment(.trailing)
                                    if (hourly) {
                                        HStack(spacing: 4) {
                                            Group {
                                                Text("\(value)")
                                                Text("/ hour")
                                            }
                                            .minimumScaleFactor(0.5)
                                            .lineLimit(1)
                                            .fixedSize()
                                            .accessibilityLabel("\(title) in hour")
                                            .accessibilityValue("\(value)")
                                            Arrow(for: value.value)
                                        }
                                    } else {
                                        Text("\(value)")
                                            .accessibilityLabel(title)
                                            .accessibilityValue("\(value)")
                                    }
                                case .pressure(let title, let value, let hourly):
                                    Text(title)
                                        .foregroundColor(.secondary)
                                    if (hourly) {
                                        HStack(spacing: 4) {
                                            Group {
                                                Text("\(value)")
                                                Text("/ hour")
                                            }
                                            .minimumScaleFactor(0.5)
                                            .lineLimit(1)
                                            .fixedSize()
                                            .accessibilityLabel("\(title) in hour")
                                            .accessibilityValue("\(value)")
                                            Arrow(for: value.value)
                                        }
                                    } else {
                                        Text("\(value)")
                                            .accessibilityLabel(title)
                                            .accessibilityValue("\(value)")
                                    }
                                }
                            }
                            if row != rows.last {
                                GradientDivider()
                                    .gridCellUnsizedAxes(.horizontal)
                            }
                        }
                    }
                    .font(.callout)
                    .padding(.bottom)
                }
            }
        }
    }
}

#Preview {
    YarTempView(model: YarTempViewModel())
}
