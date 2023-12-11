import Foundation
import SwiftUI

struct TaskView: View {
    @State private var selectedTask = "Work Presentation"
    @State private var selectedMood = "Energetic"
    @State private var selectedPriority = "High"
    @State private var startTime = Date()
    @State private var finishTime = Date().addingTimeInterval(10 * 60) // Set finish time 10 minutes later
    @State private var responseMessage: String?
    @State private var messageColor: Color = .red

    @State private var isAlertPresented = false
    
    @State private var shouldNavigateToAnalyze = false
    
    @Environment(\.presentationMode) var presentationMode
    
    let userId: String
    let bearerToken: String

    init(userId: String, bearerToken: String) {
        self.userId = userId
        self.bearerToken = bearerToken
    }
    
    let pastelBlueColor = Color(red: 0.6, green: 0.8, blue: 1.0)
    
    struct PastelBlueButtonStyle: ButtonStyle {
        let pastelBlue = Color(red: 0.6, green: 0.8, blue: 1.0)

        func makeBody(configuration: Configuration) -> some View {
            configuration.label
                .padding()
                .frame(maxWidth: .infinity)
                .background(RoundedRectangle(cornerRadius: 10).foregroundColor(pastelBlue))
                .foregroundColor(.white)
        }
    }

    var body: some View {
        NavigationView {
            
            VStack {
                VStack {
                    Text("Task")
                        .font(.headline)
                        .foregroundColor(.blue)
                    Picker(selection: $selectedTask, label: Text("")) {
                        ForEach(taskOptions, id: \.self) { task in
                            Text("\(taskEmoji(forTask: task)) \(task)")
                                .tag(task)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .foregroundColor(.blue)
                    .frame(width: UIScreen.main.bounds.width - 40)
                    .background(RoundedRectangle(cornerRadius: 8).stroke(Color.blue, lineWidth: 2))
                    .padding(EdgeInsets(top: 10, leading: 20, bottom: 15, trailing: 3))
                }
                
                VStack {
                    Text("Mood")
                        .font(.headline)
                        .foregroundColor(.blue)
                    Picker(selection: $selectedMood, label: Text("")) {
                        ForEach(moodOptions, id: \.self) { mood in
                            Text("\(moodEmoji(forMood: mood)) \(mood)")
                                .tag(mood)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .foregroundColor(.blue)
                    .frame(width: UIScreen.main.bounds.width - 40)
                    .background(RoundedRectangle(cornerRadius: 8).stroke(Color.blue, lineWidth: 2))
                    .padding(EdgeInsets(top: 10, leading: 20, bottom: 15, trailing: 3))
                }
                
                VStack {
                    Text("Priority")
                        .font(.headline)
                        .foregroundColor(.blue)
                    Picker(selection: $selectedPriority, label: Text("")) {
                        Text("High").tag("High")
                        Text("Low").tag("Low")
                        Text("Neutral").tag("Neutral")
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .foregroundColor(.blue)
                    .frame(width: UIScreen.main.bounds.width - 40)
                    .padding(EdgeInsets(top: 10, leading: 20, bottom: 10, trailing: 20))
                }
                
                let screenWidth = UIScreen.main.bounds.width
                let spacing: CGFloat = 10 // Adjust the spacing value as needed
                
                // Calculate the width for each element with spacing
                let elementWidth = (screenWidth - 60 - spacing) / 2
                
                HStack {
                    VStack {
                        Text("Start Time")
                            .font(.headline)
                            .foregroundColor(.blue)
                        DatePicker("", selection: $startTime, displayedComponents: .hourAndMinute)
                            .datePickerStyle(WheelDatePickerStyle())
                            .labelsHidden()
                            .foregroundColor(.white)
                            .frame(width: elementWidth) // Half of the screen width
                            .padding(EdgeInsets(top: 10, leading: 20, bottom: 0, trailing: 5))
                    }
                    
                    VStack {
                        Text("Finish Time")
                            .font(.headline)
                            .foregroundColor(.blue)
                        DatePicker("", selection: $finishTime, displayedComponents: .hourAndMinute)
                            .datePickerStyle(WheelDatePickerStyle())
                            .labelsHidden()
                            .foregroundColor(.white)
                            .frame(width: elementWidth) // Half of the screen width
                            .padding(EdgeInsets(top: 10, leading: 5, bottom: 0, trailing: 20))
                    }
                }
                
                Button("Create Task") {
                    createTask()
                }
                .padding()
                .frame(width: UIScreen.main.bounds.width - 40) // Adjust the width as needed
                .background(RoundedRectangle(cornerRadius: 6).foregroundColor(.blue))
                .foregroundColor(.white)
                .animation(.spring(response: 0.5, dampingFraction: 0.5, blendDuration: 0.5))
                
                HStack(spacing: 20) {
                    // Button for creating a task with pastel blue color
                    Button("Task") {
                        shouldNavigateToAnalyze = true
                    }
                    .padding()
                    .frame(maxWidth: .infinity)  // Set the frame width to infinity
                    .background(RoundedRectangle(cornerRadius: 7).foregroundColor(.blue))
                    .foregroundColor(.white)
                    .animation(.spring(response: 0.5, dampingFraction: 0.5, blendDuration: 0.5))

                    // Button for analyzing
                    Button("Analyze") {
                        shouldNavigateToAnalyze = true
                    }
                    .padding()
                    .frame(maxWidth: .infinity)  // Set the frame width to infinity
                    .buttonStyle(PastelBlueButtonStyle())
                    .animation(.spring(response: 0.5, dampingFraction: 0.5, blendDuration: 0.5))
                    .background(NavigationLink("", destination: AnalyzeView(userId: userId, bearerToken: bearerToken), isActive: $shouldNavigateToAnalyze).hidden())
                }
                .padding(.horizontal, 20)

                // Display the response message if it is not nil
                if let responseMessage = responseMessage {
                    Text(responseMessage)
                        .foregroundColor(messageColor)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(RoundedRectangle(cornerRadius: 10).foregroundColor(.white))
                        .padding(EdgeInsets(top: 10, leading: 20, bottom: 20, trailing: 20)) // Adjusted padding values
                }
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.white.edgesIgnoringSafeArea(.all))
            .navigationBarBackButtonHidden(true)
            .navigationBarItems(leading: Button(action: {
                presentationMode.wrappedValue.dismiss()
            }) {
                Image(systemName: "arrow.left")
                    .foregroundColor(.blue)
            })
        }
    }

    // Task and Mood Options
    private var taskOptions: [String] {
        [
            "Work Presentation", "Grocery Shopping", "Home Cleaning",
            "Job Interview Preparation", "Fitness Routine", "Meal Planning and Cooking",
            "Budgeting", "Academic Study Session", "Home Repairs",
            "Event Planning", "Career Development", "Volunteer Work",
            "Travel Planning", "Time Management", "Technology Troubleshooting"
        ]
    }

    private var moodOptions: [String] {
        [
            "Energetic", "Focused", "Determined", "Creative", "Relaxed", "Stressed",
            "Satisfied", "Overwhelmed", "Tired", "Unmotivated", "Angry"
        ]
    }

    // Emoji Functions
    func taskEmoji(forTask task: String) -> String {
        switch task {
        case "Work Presentation": return "📊"
        case "Grocery Shopping": return "🛒"
        case "Home Cleaning": return "🏠"
        case "Job Interview Preparation": return "👔"
        case "Fitness Routine": return "💪"
        case "Meal Planning and Cooking": return "🍳"
        case "Budgeting": return "💰"
        case "Academic Study Session": return "📚"
        case "Home Repairs": return "🛠️"
        case "Event Planning": return "🎉"
        case "Career Development": return "💼"
        case "Volunteer Work": return "🤝"
        case "Travel Planning": return "✈️"
        case "Time Management": return "⏰"
        case "Technology Troubleshooting": return "🔧"
        default: return ""
        }
    }

    func moodEmoji(forMood mood: String) -> String {
        switch mood {
        case "Energetic": return "😄"
        case "Focused": return "😌"
        case "Determined": return "😤"
        case "Creative": return "🎨"
        case "Relaxed": return "😌"
        case "Stressed": return "😓"
        case "Satisfied": return "😊"
        case "Overwhelmed": return "😵"
        case "Tired": return "😫"
        case "Unmotivated": return "😒"
        case "Angry": return "😠"
        default: return ""
        }
    }

    // Function to create the task
    func createTask() {
        // Construct the URL with userId
        guard let url = URL(string: "http://localhost:8097/tasks/\(userId)") else {
            print("Invalid URL")
            return
        }

        let json: [String: Any] = [
            "userId": 11,
            "mood": selectedMood,
            "title": selectedTask,
            "startTime": formatDate(startTime),
            "finishTime": formatDate(finishTime),
            "description": "empty",
            "priority": selectedPriority
        ]

        print("Request JSON: \(json)")

        guard let jsonData = try? JSONSerialization.data(withJSONObject: json) else {
            print("Error encoding JSON data")
            return
        }

        print(bearerToken)

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        // Set the Authorization header with the bearerToken
        request.addValue("Bearer \(bearerToken)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData

        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                print("Error: \(error)")
                return
            }

            if let httpResponse = response as? HTTPURLResponse {
                print("HTTP Response Status Code: \(httpResponse.statusCode)")

                if httpResponse.statusCode == 200 {
                    // Task created successfully
                    if let data = data {
                        if let responseString = String(data: data, encoding: .utf8) {
                            DispatchQueue.main.async {
                                self.responseMessage = responseString
                                self.messageColor = .green
                            }
                        }
                    }
                } else if httpResponse.statusCode == 400 {
                    // Handle the case where finish time is earlier than start time
                    if let data = data {
                        print(response)
                        if let responseString = String(data: data, encoding: .utf8) {
                            DispatchQueue.main.async {
                                self.responseMessage = responseString
                                self.messageColor = .red
                            }
                        }
                    }
                } else {
                    // Display an alert for other response codes
                    DispatchQueue.main.async {
                        self.showErrorResponseAlert()
                    }
                }
            }
        }.resume()
    }

    func showErrorResponseAlert() {
        isAlertPresented = true
        responseMessage = "An error occurred, Please report to: camilaomarova@gmail.com"
    }

    func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
}
