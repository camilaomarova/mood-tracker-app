import Charts
import SwiftUI
import UIKit

struct AnalyzeView: View {
    let userId: String
    let bearerToken: String
    
    init(userId: String, bearerToken: String) {
        self.userId = userId
        self.bearerToken = bearerToken
    }
    
    let pastelBlueColor = Color(red: 0.6, green: 0.8, blue: 1.0)
    
    private var timeRanges: [(String, String)] = []
    private var mood: String = ""
    
    @State private var shouldNavigateToTask = false
    @State private var totalMinutesData: [String: Int] = [:]
    @State private var timeRangesData: [String: [(String, String)]] = [:]
    @State private var analysisResult: String = ""
    
    var body: some View {
        ScrollView {
            VStack {
                Text("Analysis of your tasks")
                    .font(.largeTitle)
                    .foregroundColor(.blue)
                    .padding(.top, 3)
                
                Text("It is recommended to create at least 1 positive mood task and 1 negative for a better result")
                    .font(.custom("Courier", size: 17))
                    .foregroundColor(pastelBlueColor)
                    .padding()
                    .lineLimit(nil)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                
                Spacer(minLength: 50)
                
                Text(analysisResult)
                    .font(.custom("Courier", size: 16))
                    .foregroundColor(.blue)
                    .padding()
                    .lineLimit(nil)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                
                Spacer().frame(height: 50)
                
                Spacer(minLength: 50)
                
                // Draw bar graph for "Total minutes spent in a mood"
                SimpleLineChartView(totalMinutesData: totalMinutesData)
                    .padding()
                    .frame(maxWidth: .infinity, maxHeight: 250)
                
                Spacer(minLength: 50)
                
                Spacer().frame(height: 72)
                
                // Draw bar graph for "Total minutes spent in a mood"
                BarGraph(data: totalMinutesData, legend: "Mood", title: "")
                
                // Draw bar graph for "Pleasant Time Ranges for Tasks Completions"
//                BarGraph(data: timeRangesData, legend: "Mood Time Range", title: "Pleasant Time Ranges for Tasks Completions")
                
                // Integrate the TimeRangesView here
                ClockView(timeRangesData: timeRangesData)
                    .padding()
                
                VStack(alignment: .leading, spacing: 10) {
                    LegendRow(label: "Energetic", color: Color(UIColor(red: 1.0, green: 0.843, blue: 0.0, alpha: 1.0)))
                    LegendRow(label: "Focused", color: .orange)
                    LegendRow(label: "Determined", color: .yellow)
                    LegendRow(label: "Creative", color: .green)
                    LegendRow(label: "Relaxed", color: .blue)
                    LegendRow(label: "Stressed", color: .purple)
                    LegendRow(label: "Satisfied", color: .cyan)
                    LegendRow(label: "Overwhelmed", color: Color(red: 0.6, green: 0.2, blue: 0.8, opacity: 1.0))
                    LegendRow(label: "Tired", color: .brown)
                    LegendRow(label: "Unmotivated", color: .gray)
                    LegendRow(label: "Angry", color: .black)
                }
                .padding()
            }
            .padding(.top, 20)
            .onAppear {
                fetchData()
            }
        }
    }
    
    private func angle(for time: String) -> Angle {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        guard let date = dateFormatter.date(from: time) else {
            return Angle(degrees: 0)
        }
        
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute], from: date)
        
        guard let hour = components.hour, let minute = components.minute else {
            return Angle(degrees: 0)
        }
        
        // Calculate the angle based on hour and minute components
        let hourAngle = Angle(degrees: Double((hour % 12) * 30 + minute / 2))
        
        return hourAngle
    }
    
    private func labelPosition(for angle: Double, in radius: CGFloat) -> CGPoint {
        let smallerRadius = radius * 0.4 // Adjust the scale factor (0.4) as needed
        let radians = angle * .pi / 180
        let x = smallerRadius * cos(CGFloat(radians))
        let y = smallerRadius * sin(CGFloat(radians))
        let centerX = CGFloat(200) / 2 // Center of the circle
        let centerY = CGFloat(200) / 2 // Center of the circle
        
        // Apply the scale factor only to the x-coordinate of the numbers
        let mirroredX = -x
        
        return CGPoint(x: centerX + mirroredX, y: centerY + y)
    }
    
    private func color(for mood: String) -> Color {
        // Assign a unique color for each mood or use a predefined color scheme
        // Modify this method based on your color preferences
        switch mood {
        case "Energetic":
            return Color(UIColor(red: 1.0, green: 0.843, blue: 0.0, alpha: 1.0))
        case "Focused":
            return .orange
        case "Determined":
            return .yellow
        case "Creative":
            return .green
        case "Relaxed":
            return .blue
        case "Stressed":
            return .purple
        case "Satisfied":
            return .cyan
        case "Overwhelmed":
            return Color(red: 0.6, green: 0.2, blue: 0.8, opacity: 1.0)
        case "Tired":
            return .brown
        case "Unmotivated":
            return .gray
        case "Angry":
            return .black
        default:
            return .gray
        }
    }
    
    private func fetchData() {
        // Data fetching logic
        guard let url = URL(string: "http://localhost:8097/tasks/analyze/\(userId)") else {
            print("Invalid URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("Bearer \(bearerToken)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard error == nil else {
                print("Error: \(String(describing: error))")
                // Handle the error appropriately (show an alert, update UI, etc.)
                return
            }

            guard let data = data else {
                print("No data received")
                // Handle the case where no data is received (show an alert, update UI, etc.)
                return
            }
        
            do {
                let response = try JSONDecoder().decode(Response.self, from: data)
                
                let resultString = String(data: data, encoding: .utf8)
                
                let (totalMinutesData, timeRangesData) = parseData(from: response)
                
                DispatchQueue.main.async {
                    self.totalMinutesData = totalMinutesData
                    self.timeRangesData = timeRangesData
                    self.analysisResult = resultString ?? ""
                }
            } catch {
                print("Error decoding JSON:", error)
            }
        }.resume()
    }
                    
    
    private func parseData(from response: Response) -> ([String: Int], [String: [(String, String)]]) {
        // Parse your response and extract the necessary data
        totalMinutesData = response.totalMinutesSpentInAMood
        timeRangesData = response.pleasantTimeRangesForTasksCompletions
        
        return (totalMinutesData, timeRangesData)
    }
}

struct LegendRow: View {
    var label: String
    var color: Color

    var body: some View {
        HStack {
            Circle()
                .fill(color)
                .frame(width: 15, height: 15)
            Text(label)
                .font(.headline)
        }
    }
}

struct SimpleLineChartView: View {
    let totalMinutesData: [String: Int]

    var body: some View {
        VStack {
            Spacer()
            Spacer()
            Spacer()
            Spacer()
            Spacer()
            Spacer()
            Spacer()
            Spacer()
            Spacer()
            Spacer()
            Spacer()
            Spacer()
            Spacer()
            Spacer()
            Spacer()
            Spacer()
            
            Text("Total Minutes Spent in a Mood")
                .font(.headline)
                .padding()

            Chart {
                ForEach(totalMinutesData.sorted(by: { $0.key < $1.key }), id: \.key) { (mood, value) in
                    LineMark(x: .value(mood, mood), y: .value("Total Minutes", Double(value)))
                        .foregroundStyle(Color.blue)
                        .interpolationMethod(.catmullRom)
                        .symbol(.circle)
                }
            }
            .chartXScale(range: .plotDimension(padding: 20.0))
            .chartXAxis {
                AxisMarks(preset: .aligned, position: .top, values: .stride(by: .day)) { value in
                    AxisValueLabel(format: .dateTime.day().weekday(.narrow))
                }
            }
            .chartPlotStyle { plotArea in
                plotArea.frame(maxWidth: .infinity, minHeight: 250.0, maxHeight: 250.0)
            }
            .chartYAxis {
                AxisMarks(position: .leading)
            }

            // Legend as a list
            VStack(alignment: .leading, spacing: 10) {
                ForEach(totalMinutesData.sorted(by: { $0.key < $1.key }), id: \.key) { (mood, _) in
                    LegendItem(color: Color.blue, label: mood)
                }
            }
            .padding(.bottom, 10)
            
            Spacer()
            Spacer()
            Spacer()
            Spacer()
            Spacer()
        }
    }
}

struct LegendItem: View {
    let color: Color
    let label: String

    var body: some View {
        HStack(spacing: 5) {
            RoundedRectangle(cornerRadius: 5)
                .fill(color)
                .frame(width: 15, height: 15)
            Text(label)
                .font(.caption)
                .lineLimit(1) // Set line limit to 1 to prevent truncation
                .minimumScaleFactor(0.5) // Adjust the minimum scale factor as needed
        }
    }
}

struct ResponseModel: Decodable {
    let result: String
}

struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .frame(maxWidth: .infinity)
            .background(RoundedRectangle(cornerRadius: 10).foregroundColor(.blue))
            .foregroundColor(.white)
    }
}

struct BarGraph: View {
    let data: [String: Any]?
    let legend: String
    let title: String

    var body: some View {
        VStack {
            Text(title)
                .font(.headline)
                .padding()

            if let data = data {
                HStack(alignment: .bottom, spacing: 10) {
                    ForEach(data.sorted(by: { $0.key < $1.key }), id: \.key) { (mood, value) in
                        VStack {
                            Text(mood)
                                .font(.caption)
                                .foregroundColor(.blue)

                            if let intValue = value as? Int {
                                // Bar graph for Int values
                                RoundedRectangle(cornerRadius: 5)
                                    .fill(Color.blue)
                                    .frame(width: 30, height: CGFloat(intValue))
                            } else if let timeRanges = value as? [(String, String)] {
                                // Bar graph for time range values
                                RoundedRectangle(cornerRadius: 5)
                                    .fill(Color.blue)
                                    .frame(width: 30, height: CGFloat(timeRanges.count * 20))
                            }
                        }
                    }
                }
            }

            Text(legend)
                .font(.caption)
                .padding(.bottom, 10)
        }
        .padding()
    }
}

struct PastelBlueButtonStyle: ButtonStyle {
    let pastelBlueColor = Color(red: 0.6, green: 0.8, blue: 1.0)

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .frame(maxWidth: .infinity)
            .background(RoundedRectangle(cornerRadius: 10).foregroundColor(pastelBlueColor))
            .foregroundColor(.white)
    }
}

struct ClockView: View {
    let timeRangesData: [String: [(String, String)]]

    var body: some View {
        VStack {
            Text("Pleasant Time Ranges on Clock")
                .font(.headline)
                .lineLimit(nil)
            ZStack {
                // Rotate the entire clock by -90 degrees
                ForEach(timeRangesData.sorted(by: { $0.key < $1.key }), id: \.key) { (mood, ranges) in
                    ForEach(ranges.indices, id: \.self) { index in
                        let range = ranges[index]
                        
                        if angle(for: range.0) < angle(for: range.1) {
                            let timeIsOnRightSide: Bool = angle(for: range.0) < 180
                            
                            // Draw other moods in their respective colors
                            PieSlice(startAngle: angle(for: range.0),
                                     endAngle: angle(for: range.1))
                            .foregroundColor(Color(color(for: mood)))
                            .background(content: {
                                Circle()
                                    .strokeBorder(Color.black, lineWidth: 2)
                            })
                            .overlay(
                                Text(String(mood.prefix(4)))
                                    .font(.caption)
                                    .foregroundColor(.white)
                                    .rotationEffect(timeIsOnRightSide ? .degrees(angle(for: range.0)) : .degrees(angle(for: range.0) + 180))
                                    .position(labelPosition(for: angle(for: range.0) + 3, in: 70))
                            )
                        }
                    }
                }

                // Numbers should be visually rotated but not their places
                ForEach(1..<13) { hour in
                    Text("\(hour)")
                        .font(.system(size: 18).weight(.bold)) // Adjust the font size as needed
                        .rotationEffect(.degrees(90)) // Rotate the number text visually
                        .position(labelPosition(for: Double(hour) * 30, in: 90)) // Adjust the radius as needed
                }
            }
            .frame(width: 240, height: 240)
            .background(content: {
                Circle()
                    .strokeBorder(Color.black, lineWidth: 2)
            })
            .background(Color.white)
            .rotationEffect(.degrees(-90)) // Rotate the entire clock back to its original position
        }
    }
    
    private func color(for mood: String) -> UIColor {
        switch mood {
        case "Energetic":
            return UIColor(red: 1.0, green: 0.843, blue: 0.0, alpha: 1.0)
        case "Focused":
            return .orange
        case "Determined":
            return .yellow
        case "Creative":
            return .green
        case "Relaxed":
            return .blue
        case "Stressed":
            return .purple
        case "Satisfied":
            return .cyan
        case "Overwhelmed":
            return .systemPink
        case "Tired":
            return .brown
        case "Unmotivated":
            return .darkGray
        case "Angry":
            return .black
        default:
            return .gray
        }
    }

    private func angle(for time: String) -> Double {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        guard let date = dateFormatter.date(from: time) else {
            return 0
        }

        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute], from: date)

        guard let hour = components.hour, let minute = components.minute else {
            return 0
        }
        let adjustedHour = hour % 12
        let hourAngle = Double(adjustedHour * 30)
        let minuteAngle = Double(minute) / 2.0
        // Combine the hour and minute angles
        let totalAngle = hourAngle + minuteAngle
        return totalAngle
    }

    private func labelPosition(for angle: Double, in radius: CGFloat) -> CGPoint {
        let radians = angle * .pi / 180
        let x = radius * cos(CGFloat(radians))
        let y = radius * sin(CGFloat(radians))
        let centerX = CGFloat(120) // Center of the clock
        let centerY = CGFloat(120) // Center of the clock

        return CGPoint(x: centerX + x, y: centerY + y)
    }
}

struct PieSlice: Shape {
    var startAngle: Double
    var endAngle: Double

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) / 2
            

        path.move(to: center)
        path.addArc(center: center, radius: radius, startAngle: .degrees(startAngle), endAngle: .degrees(endAngle), clockwise: false)
        path.closeSubpath()

        return path
    }
}
