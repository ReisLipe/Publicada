//
//  PublicadaSignInApp.swift
//  PublicadaSignIn
//
//  Created by Joao Filipe Reis Justo da Silva on 19/09/24.
//

import SwiftUI

@main
struct PublicadaApp: App {
    @StateObject var loginController: LoginController = LoginController()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }.environmentObject(loginController)
    }
}
