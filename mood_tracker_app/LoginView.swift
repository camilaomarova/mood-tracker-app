//
//  LoginView.swift
//  mood_tracker_app
//
//  Created by Camila Omarova on 19.11.2023.
//

import SwiftUI

struct LoginView: View {
    @State private var username = ""
    @State private var password = ""
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var bearerToken: String?
    @State private var userId: String?
    @State private var shouldNavigate: Bool = false
    @State private var isFirstLogin: Bool = true // Track if it's the first login

    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        NavigationView {
            VStack {
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 80, height: 80)
                    .foregroundColor(.blue)

                Text("Welcome back!")
                    .font(.title)
                    .foregroundColor(.blue)

                Text("Login to your account")
                    .font(.subheadline)
                    .foregroundColor(.blue)

                TextField("Username", text: $username)
                    .padding()
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(10)

                SecureField("Password", text: $password)
                    .padding()
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(10)

                Button(action: {
                    // Perform login
                    login()
                }) {
                    Text("Login")
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                .alert(isPresented: $showAlert) {
                    Alert(title: Text("Error"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
                }

//                NavigationLink(destination: TaskView(userId: userId ?? "", bearerToken: bearerToken ?? ""), isActive: $shouldNavigate) {
//                    EmptyView()
//                }
//                .isDetailLink(false) // Disable automatic navigation link creation
                NavigationLink(destination: TaskView(userId: userId ?? "", bearerToken: bearerToken ?? ""), isActive: $shouldNavigate) {
                    EmptyView()
                }
                .isDetailLink(false) // Disable automatic navigation link creation
                .navigationBarHidden(true) // Hide navigation bar in the intermediate view


                NavigationLink(destination: RegisterView()) {
                    Text("Don't have an account? Register here")
                        .foregroundColor(.blue)
                        .padding(.top, 10)
                }

                Spacer()

                HStack(spacing: 23) {
                    // Use a conditional NavigationLink for the "Login" action
                    if isFirstLogin {
                        Button(action: {
                            login()
                        }) {
                            HStack {
                                Image(systemName: "person.circle.fill")
                                    .font(.title)
                                    .foregroundColor(.blue)
                                Text("Login")
                                    .font(.title)
                            }
                        }
                    } else {
                        NavigationLink(destination: TaskView(userId: userId ?? "", bearerToken: bearerToken ?? ""), isActive: $shouldNavigate) {
                            EmptyView()
                        }
                        .isDetailLink(false) // Disable automatic navigation link creation
                        .hidden() // Hide the NavigationLink
                    }


                    NavigationLink(destination: RegisterView()) {
                        HStack {
                            Text("Register")
                                .font(.title)
                            Image(systemName: "person.badge.plus.fill")
                                .font(.title)
                                .foregroundColor(.blue)
                        }
                    }
                }
                .padding(.bottom, 70)
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.white)
        }
    }

    private func login() {
        let url = URL(string: "http://localhost:8097/login")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: String] = [
            "username": username,
            "password": password
        ]

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
        } catch {
            print("Error encoding JSON: \(error)")
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, let httpResponse = response as? HTTPURLResponse else {
                print("Error: \(error?.localizedDescription ?? "Unknown error")")
                showAlert(message: "An error occurred. Please try again.")
                return
            }

            if httpResponse.statusCode == 200 {
                do {
                    let loginResponse = try JSONDecoder().decode(LoginResponse.self, from: data)
                    bearerToken = loginResponse.token
                    userId = loginResponse.userId

                    // Set shouldNavigate to true to trigger NavigationLink
                    shouldNavigate = true

                } catch {
                    print("Error decoding JSON: \(error)")
                    showAlert(message: "An error occurred. Please try again.")
                }
            } else if httpResponse.statusCode == 401 {
                showAlert(message: "Invalid Credentials. Please try again.")
            } else {
                showAlert(message: "An unexpected error occurred. Please try again.")
            }
        }.resume()
    }

    private func showAlert(message: String) {
        alertMessage = message
        showAlert = true
    }
}

struct LoginResponse: Decodable {
    let token: String
    let userId: String
}

