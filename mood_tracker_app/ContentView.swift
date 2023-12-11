//
//  ContentView.swift
//  mood_tracker_app
//
//  Created by Camila Omarova on 19.11.2023.
//

//import SwiftUI
//
//struct ContentView: View {
//    var body: some View {
//        NavigationView {
//            LoginView()
//            .tabItem {
//                Label("Tasks", systemImage: "key.fill")
//            }
//            RegisterView()
//                .tabItem {
//                    Label("Register", systemImage: "person.crop.circle.badge.plus")
//                }
//        }
//    }
//}
import SwiftUI

struct ContentView: View {
    @State private var isLoggedIn = false
    @State private var bearerToken: String?
    @State private var userId: String?

    var body: some View {
        NavigationView {
            if isLoggedIn {
                TabView {
                    TaskView(userId: userId ?? "", bearerToken: bearerToken ?? "")
                        .tabItem {
                            Label("Tasks", systemImage: "list.bullet")
                        }
                    AnalyzeView(userId: userId ?? "", bearerToken: bearerToken ?? "")
                        .tabItem {
                            Label("Analyze", systemImage: "chart.bar.xaxis")
                        }
                }
            } else {
                LoginView()
                    .tabItem {
                        Label("Login", systemImage: "key.fill")
                    }

                RegisterView()
                    .tabItem {
                        Label("Register", systemImage: "person.crop.circle.badge.plus")
                    }
            }
        }
    }
}
