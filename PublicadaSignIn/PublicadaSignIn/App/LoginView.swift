//
//  LoginView.swift
//  Publicada
//
//  Created by Joao Filipe Reis Justo da Silva on 18/09/24.
//

import SwiftUI
import AuthenticationServices

struct LoginView: View {
    // Aqui chamamos o objeto de ambiente declarado em 'PublicadaApp'
    @EnvironmentObject var loginController: LoginController
    
    @State var userID: String?
    @State var userName: String?
    @State var userEmail: String?
    
    @State var signInError: Bool = false
    @State var nextView: Bool = false
    
    var body: some View {
        NavigationStack{
            ZStack{
                // Background
                Color.mint
                    .ignoresSafeArea()
                
                // Foreground
                VStack(spacing: 30){
                    Spacer()
                    
                    Text("Hello, user!")
                        .font(.system(size: 30, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                    
                    Image(systemName: "apple.logo")
                        .resizable()
                        .scaledToFit()
                        .foregroundColor(.white)
                        .frame(width: 100, height: 100)
                    
                    Spacer()
                    
                    // Continue With Apple Button
                    SignInWithAppleButton(.continue) { request in
                        request.requestedScopes = [.fullName, .email]
                    } onCompletion: { result in
                        switch result {
                            case.success(let authoriation):
                                handleAuthorizationSuccess(authoriation)
                            case.failure(let error):
                                handleAuthorizationFailure(error)
                        }
                    }
                    .frame(width: 284, height: 54)
                    
                    // Hidden error message
                    Text("Error trying to continue with Apple.")
                        .bold()
                        .foregroundStyle(signInError ? .red : .clear)
                }
            }.navigationDestination(isPresented: $nextView) {
                HomeView().navigationBarBackButtonHidden()
            }
        }
    }
    
    private func handleAuthorizationSuccess(_ authorization: ASAuthorization) {
        if let userCredentials = authorization.credential as? ASAuthorizationAppleIDCredential {
            
            let userIdentifier = userCredentials.user
            let userName = userCredentials.fullName?.givenName ?? ""
            let userEmail = userCredentials.email ?? ""
            
            print("Authorization success:")
            print("Identificador: \(userIdentifier)")
            print("Nome: \(String(describing: userName))")
            print("Email: \(String(describing: userEmail))")
            
            // 'Task' permite chamar um bloco assíncrono em nossa view
            Task {
                do {
                    try await loginController.manageSignIn(
                        userIndentifier: userIdentifier,
                        name: userName,
                        email: userEmail
                    )
                    nextView = true
                } catch {
                    print("Error while signIn: \(error.localizedDescription)")
                }
            }
        }
    }
    
    private func handleAuthorizationFailure(_ error: Error) {
        signInError = true
        print("Ahtorization failure: \(error.localizedDescription)")
    }
}

#Preview {
    LoginView()
}
