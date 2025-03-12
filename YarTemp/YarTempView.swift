//
//  YarTempView.swift
//  YarTemp
//
//  Created by Iliya Prostakishin on 16.04.2024.
//

import SwiftUI

// MARK: - Header

// MARK: This shape was generated automatically, using https://svg-to-swiftui.quassum.com/
// Source SVG:
// <svg width="45" height="50" viewBox="0 0 45 50" fill="none" xmlns="http://www.w3.org/2000/svg">
// <path d="M0.5 0H44.5V50H33.6672C25.426 50 18.0285 44.9449 15.0341 37.2669L0.5 0Z" fill="#D9D9D9"/>
// </svg>
/*
struct HeaderPart: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.size.width
        let height = rect.size.height
        path.move(to: CGPoint(x: 0.01111*width, y: 0))
        path.addLine(to: CGPoint(x: 0.98889*width, y: 0))
        path.addLine(to: CGPoint(x: 0.98889*width, y: height))
        path.addLine(to: CGPoint(x: 0.74816*width, y: height))
        path.addCurve(to: CGPoint(x: 0.33409*width, y: 0.74534*height), control1: CGPoint(x: 0.56502*width, y: height), control2: CGPoint(x: 0.40063*width, y: 0.8989*height))
        path.addLine(to: CGPoint(x: 0.01111*width, y: 0))
        path.closeSubpath()
        return path
    }
}

@ViewBuilder
func Header() -> some View {
    VStack {
        HStack(spacing: 0) {
            Spacer()
            
            ZStack {
                HeaderPart()
                    .fill(Color("HeaderBackground"))
                    .frame(width: 15, height: 19)
                // There is a "discrepancy gap", because of floating point calculations, so we need to fill the gap using additional rectangle.
                Rectangle()
                    .fill(Color("HeaderBackground"))
                    .frame(width: 2, height: 19)
                    .padding(.leading, 13)
            }
            
            Text("YarTemp")
                .frame(width: 56, height: 19)
                .textCase(.uppercase)
                .font(.caption)
                .foregroundColor(Color("HeaderText"))
                .padding(.leading, 0)
                .padding(.trailing, 10)
                .background(UnevenRoundedRectangle(cornerRadii: .init(
                    topLeading: 0,
                    bottomLeading: 0,
                    bottomTrailing: 0,
                    topTrailing: 10)).fill(Color("HeaderBackground")))
        }
        
        Spacer()
    }
}
*/

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
                    //.background(ContainerRelativeShape().fill(Color("HeaderBackground")))
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
