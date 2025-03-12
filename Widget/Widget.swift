//
//  Widget.swift
//  Widget
//
//  Created by Iliya Prostakishin on 22.04.2024.
//

import WidgetKit
import SwiftUI

extension YarTempWidget {
    struct Provider: TimelineProvider {
        typealias Entry = YarTempWidget.Entry
       
        func placeholder(in context: Context) -> Entry {
            Entry()
        }
    
        func getSnapshot(in context: Context, completion: @escaping (Entry) -> Void) {
            let entry = Entry()
            completion(entry)
        }
        
        func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> Void) {
            let currentDate = Date()
            Task {
                let model = YarTempViewModel()
                await model.refresh()
                let entry = Entry(model)
                let nextUpdate = Calendar.current.date(byAdding: .minute, value: 15, to: currentDate)!
                let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
                completion(timeline)
            }
        }
    }
}

extension YarTempWidget {
    struct Entry: TimelineEntry {
        var date: Date = .init()
        var temperature = Measurement<UnitTemperature>(value: 0, unit: .celsius)
        var temperatureChange = Measurement<UnitTemperature>(value: 0, unit: .celsius)
        var temperatureDayMin = Measurement<UnitTemperature>(value: 0, unit: .celsius)
        var temperatureDayMax = Measurement<UnitTemperature>(value: 0, unit: .celsius)
        var temperatureDayAverage = Measurement<UnitTemperature>(value: 0, unit: .celsius)
        var temperatureDayLastYear = Measurement<UnitTemperature>(value: 0, unit: .celsius)
        var pressure = Measurement<UnitPressure>(value: 0, unit: .millimetersOfMercury)
        var pressureChange = Measurement<UnitPressure>(value: 0, unit: .millimetersOfMercury)
        var error: Error? = nil
        var temperatureChangeImage: Image {
            get {
                let name = temperatureChange.value < 1 ? Arrow.imageDown : Arrow.imageUp
                return Image(systemName: name)
            }
        }
        init(_ model: YarTempViewModel? = nil) {
            if let m = model {
                temperature = m.temperature
                temperatureChange = m.temperatureChange
                temperatureDayMin = m.temperatureDayMin
                temperatureDayMax = m.temperatureDayMax
                temperatureDayAverage = m.temperatureDayAverage
                temperatureDayLastYear = m.temperatureDayLastYear
                pressure = m.pressure
                pressureChange = m.pressureChange
                error = m.error
            }
        }
    }
}

struct WidgetEntryView : View {
    var entry: YarTempWidget.Provider.Entry
    @Environment (\.widgetFamily) var family
    
    var body: some View {
        ZStack {
            switch(family) {
            case .systemLarge:
                LargeSizedWidget()
            case .systemMedium:
                MediumSizedWidget()
#if os(iOS)
            case .accessoryInline:
                if #available(iOS 16, *) {
                    InlineWidget()
                }
            case .accessoryRectangular:
                if #available(iOS 16, *) {
                    RectangularWidget()
                }
            case .accessoryCircular:
                if #available(iOS 16, *) {
                    CircularWidget()
                }
#endif
            default:
                SmallSizedWidget()
            }
        }
    }
        
    @ViewBuilder
    func MediumSizedWidget() -> some View {
        ZStack {
            if entry.error != nil {
                Text("No temperature data", comment: "Data error message in medium temperature widget")
            } else {
                ZStack {
                    Header()
                    HStack(alignment: .top) {
                        Termometer(for: entry.temperature.value)
                        Text("\(entry.temperature)")
                            .font(.system(size: 32))
                            .frame(height: 32)
                            .accessibilityLabel("temperature")
                            .accessibilityValue("\(entry.temperature)")
                        VStack(alignment: .leading) {
                            HStack {
                                Text("\(entry.temperatureChange) / hour")
                                Arrow(for: entry.temperatureChange.value)
                            }
                            HStack(alignment: .top, spacing: 0) {
                                Text("H:")
                                    .foregroundColor(.secondary)
                                    .frame(width: 18, alignment: .leading)
                                    .accessibilityLabel("Day high")
                                Text("\(entry.temperatureDayMax)")
                                    .accessibilityLabel("Day high")
                                    .accessibilityValue("\(entry.temperatureDayMax)")
                            }
                            HStack(alignment: .top, spacing: 0){
                                Text("L:")
                                    .foregroundColor(.secondary)
                                    .frame(width: 18, alignment: .leading)
                                    .accessibilityLabel("Day low")
                                Text("\(entry.temperatureDayMin)")
                                    .accessibilityLabel("Day low")
                                    .accessibilityValue("\(entry.temperatureDayMin)")
                            }
                            Text("\(entry.pressure)")
                        }
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    func SmallSizedWidget() -> some View {
        if entry.error != nil {
            Text("No temperature data", comment: "Data error message in small temperature widget")
        } else {
            ZStack {
                Header()
                HStack(alignment: .top) {
                    Termometer(for: entry.temperature.value)
                    VStack(alignment: .leading) {
                        HStack(alignment: .top) {
                            Text("\(entry.temperature)")
                                .font(.system(size: 32))
                                .frame(height: 32)
                                .accessibilityLabel("temperature")
                                .accessibilityValue("\(entry.temperature)")
                            Arrow(for: entry.temperatureChange.value)
                                .padding(.top, 4)
                        }
                        .frame(alignment: .top)
                        //.border(.red)
                        VStack(alignment: .leading) {
                            HStack(spacing: 0) {
                                Text("H:")
                                    .foregroundColor(.secondary)
                                    .frame(width: 18, alignment: .leading)
                                    .accessibilityLabel("Day high")
                                Text("\(entry.temperatureDayMax)")
                                    .accessibilityLabel("Day high")
                                    .accessibilityValue("\(entry.temperatureDayMax)")
                            }
                            HStack(spacing: 0) {
                                Text("L:")
                                    .foregroundColor(.secondary)
                                    .frame(width: 18, alignment: .leading)
                                    .accessibilityLabel("Day low")
                                Text("\(entry.temperatureDayMin)")
                                    .accessibilityLabel("Day low")
                                    .accessibilityValue("\(entry.temperatureDayMin)")
                            }
                        }
                    }
                    .lineLimit(1)
                    .fixedSize()
                }
                .frame(alignment: .top)
                //.border(.green)
            }
        }
    }
    
    @ViewBuilder
    func LargeSizedWidget() -> some View {
        if entry.error != nil {
            Text("No temperature data", comment: "Data error message in medium temperature widget")
        } else {
            YarTempView(temperature: entry.temperature,
                        temperatureChange: entry.temperatureChange,
                        temperatureDayMin: entry.temperatureDayMin,
                        temperatureDayMax: entry.temperatureDayMax,
                        temperatureDayAverage: entry.temperatureDayAverage,
                        temperatureDayLastYear: entry.temperatureDayLastYear,
                        pressure: entry.pressure,
                        pressureChange: entry.pressureChange)
        }
    }
    
    // MARK: There are Lock Screen widgets. Some of them are layout-sensitive.
    // Therefore, it's better to prefer simple layouts (just Text(), for example).
    
    @available(iOS 16, *)
    @ViewBuilder
    func InlineWidget() -> some View {
        if entry.error != nil {
            Text("No data", comment: "Data error message in inline temperature widget")
        } else {
            Text("\(entry.temperature) \(entry.temperatureChangeImage)")
            // HStack is not working here, use simple Text() instead.
            // https://forums.developer.apple.com/forums/thread/712656
            //HStack() {
            //    Text("\(entry.temperature)")
            //    Arrow(for: entry.temperatureChange.value)
            //}
        }
    }
    
    @available(iOS 16, *)
    @ViewBuilder
    func RectangularWidget() -> some View {
        if entry.error != nil {
            Text("No data", comment: "Data error message in rectangular temperature widget")
        } else {
            HStack()
            {
                Termometer(for: entry.temperature.value)
                VStack(alignment: .leading) {
                    Text("\(entry.temperature) \(entry.temperatureChangeImage)")
                    Text("H:\(entry.temperatureDayMax) L:\(entry.temperatureDayMin)")
                }
            }
        }
    }
    
    @available(iOS 16, *)
    @ViewBuilder
    func CircularWidget() -> some View {
        if entry.error != nil {
            Text("No data", comment: "Data error message in circular temperature widget")
        } else {
            ZStack {
                Gauge(value: entry.temperature.value, in: entry.temperatureDayMin.value...entry.temperatureDayMax.value) {
                    Text("\(entry.temperatureChangeImage)")
                }
                .gaugeStyle(.accessoryCircular)
                Text("\(entry.temperature)")
            }
        }
    }
}

struct YarTempWidget: Widget {
    var supportedFamilies: [WidgetFamily] {
#if os(iOS)
        if #available(iOS 16, *) {
            return [.systemSmall, .systemMedium, .systemLarge, .accessoryInline, .accessoryRectangular, .accessoryCircular]
        }
#endif
        return [.systemSmall, .systemMedium, .systemLarge ]
    }

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "YarTemp", provider: Provider()) { entry in
            if #available(macOS 14, iOS 17, *) {
                WidgetEntryView(entry: entry)
                    .containerBackground(.fill.tertiary, for: .widget)
                    .environment(\.headerRadius, 50)
            } else {
                WidgetEntryView(entry: entry)
                    .background()
                    .environment(\.headerRadius, 50)
            }
        }
        .contentMarginsDisabled()
        .configurationDisplayName(Text("YarTemp", comment: "The name shown for the widget when the user adds or edits it"))
        .description(Text("Displays the temperature and other data, recieved from YarTemp service.", comment: "Description shown for the widget when the user adds or edits it"))
    }
}

#if os(iOS)

#Preview(as: .systemSmall) {
    YarTempWidget()
} timeline: {
    YarTempWidget.Provider.Entry()
}

#endif
