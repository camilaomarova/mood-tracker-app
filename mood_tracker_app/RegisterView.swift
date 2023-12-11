//
//  RegisterView.swift
//  mood_tracker_app
//
//  Created by Camila Omarova on 19.11.2023.
//

import SwiftUI

struct RegisterView: View {
    @State private var email = ""
    @State private var username = ""
    @State private var password = ""
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var userId: String?
    @State private var bearerToken: String?
    @State private var shouldNavigate: Bool = false
    @State private var alertColor: Color = .red // You can set the initial color to red or any other default color

    var body: some View {
        NavigationView {
            VStack {
                Text("Register")
                    .font(.title2)
                
                Image(systemName: "person.badge.plus")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 50, height: 50)
                    .foregroundColor(.blue)
                    .padding(.top, 20)

                TextField("Email", text: $email)
                    .padding()
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(10)

                TextField("Username", text: $username)
                    .padding()
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(10)

                SecureField("Password", text: $password)
                    .padding()
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(10)

                TextField("First Name", text: $firstName)
                    .padding()
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(10)

                TextField("Last Name", text: $lastName)
                    .padding()
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(10)

                Button(action: {
                    // Perform registration
                    register()
                }) {
                    Text("Register")
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                .alert(isPresented: $showAlert) {
                    Alert(
                        title: Text("Error"),
                        message: Text(alertMessage).foregroundColor(.red),
                        dismissButton: .default(Text("OK"))
                    )
                }

                NavigationLink(destination: LoginView(), isActive: $shouldNavigate) {
                    EmptyView()
                }
                .navigationBarHidden(true) // Hide navigation bar in the intermediate view

            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.white)
        }
    }

    private func register() {
        let url = URL(string: "http://localhost:8097/api/users/register")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: String] = [
            "email": email,
            "username": username,
            "password": password,
            "firstName": firstName,
            "lastName": lastName
        ]

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
        } catch {
            print("Error encoding JSON: \(error)")
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, let httpResponse = response as? HTTPURLResponse else {
                print("Error: \(error?.localizedDescription ?? "Unknown error")")
                showAlert(message: "An error occurred. Please try again.", color: .red)
                return
            }

            print("HTTP Status Code: \(httpResponse.statusCode)")

            if let responseString = String(data: data, encoding: .utf8) {
                print("Response Data: \(responseString)")
            }

            if (200..<300).contains(httpResponse.statusCode) {
                // Handle success case
                do {
                    let registrationResponse = try JSONDecoder().decode(RegisterResponse.self, from: data)
                    userId = registrationResponse.userId
                    bearerToken = registrationResponse.token

                    // Set shouldNavigate to true to trigger NavigationLink
                    shouldNavigate = true

                } catch {
                    print("Error decoding JSON: \(error)")
                    showAlert(message: "An error occurred. Please try again.", color: .red)
                }
            } else if httpResponse.statusCode == 400 {
                // Handle error case
                do {
                    let errorResponse = try JSONDecoder().decode(ErrorResponse.self, from: data)
                    if let errorMessage = errorResponse.message {
                        showAlert(message: errorMessage, color: .red)
                    } else {
                        showAlert(message: "Email is already in use. Please login.", color: .red)
                    }
                } catch {
                    showAlert(message: "Email is already in use. Please login.", color: .red)
                }
            } else {
                showAlert(message: "An unexpected error occurred. Please try again.", color: .red)
            }
        }.resume()
    }

    private func showAlert(message: String, color: Color) {
        alertMessage = message
        alertColor = color
        showAlert = true
    }

    private func showAlert(message: String) {
        alertMessage = message
        showAlert = true
    }
}

struct RegisterResponse: Decodable {
    let userId: String
    let token: String
    // Add other properties if needed
}

struct ErrorResponse: Decodable {
    let message: String?
    // Add other properties if needed
}

