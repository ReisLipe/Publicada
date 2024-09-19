//
//  HomeView.swift
//  Publicada
//
//  Created by Joao Filipe Reis Justo da Silva on 18/09/24.
//

import SwiftUI

struct HomeView: View {
    // Aqui chamamos o objeto de ambiente declarado em 'PublicadaApp'
    @EnvironmentObject var loginController: LoginController
    
    @State var userName: String = ""
    @State var userEmail: String = ""
    
    @State var errorUpdatingInfo: Bool = false
    @State var errorDeletingUser: Bool = false
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack{
            // Background
            Color.mint
                .ignoresSafeArea()
            
            // Foreground
            VStack{
                Text("Hello, \(loginController.currentUser?.name ?? "User")!")
                    .font(.system(size: 40, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .padding()
                
                Spacer()
                
                Image(systemName: "smiley.fill")
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(.white)
                    .frame(width: 150, height: 150)
                
                Spacer()
                
                // Campos de update de informações
                VStack (alignment: .leading){
                    Text("Update your info:")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                    
                    TextField("Insert a new name", text: $userName)
                    TextField("Insert a new email", text: $userEmail)
                }
                .padding()
                
                // Botões
                VStack{
                    Button {
                        // 'Task' permite chamar um bloco assíncrono em nossa view
                        Task {
                            do {
                                try await loginController.updateUserInfo(
                                    name: userName,
                                    email: userEmail
                                )
                            } catch{
                                errorUpdatingInfo = true
                                print("Error trying to update info: \(error.localizedDescription)")
                            }
                        }
                    } label: {
                        ZStack{
                            RoundedRectangle(cornerRadius: 8)
                                .foregroundColor(.indigo)
                            Text("Change my info")
                                .foregroundStyle(.white)
                                .font(.system(size: 16, weight: .semibold, design: .default))
                        }
                    }.frame(width: 160, height: 50)
                    
                    Button {
                        // 'Task' permite chamar um bloco assíncrono em nossa view
                        Task {
                            do {
                                try await loginController.deleteUser()
                                dismiss()
                            } catch {
                                errorDeletingUser = true
                                print("Error trying to delete user: \(error.localizedDescription)")
                            }
                        }
                    } label: {
                        ZStack{
                            RoundedRectangle(cornerRadius: 8)
                                .foregroundColor(.indigo)
                            Text("Delete my account")
                                .foregroundStyle(.white)
                                .font(.system(size: 16, weight: .semibold, design: .default))
                        }
                    }.frame(width: 160, height: 50)
                }.padding()
                
                
                // Mensagens de erro escondidas
                ZStack{
                    Text("Error trying to update info.")
                        .bold()
                        .foregroundStyle(errorUpdatingInfo ? .red : .clear)
                    
                    Text("Error trying to delete user.")
                        .bold()
                        .foregroundStyle(errorDeletingUser ? .red : .clear)
                }
                                
                Spacer()
            }
        }
    }
}

#Preview {
    HomeView()
}
