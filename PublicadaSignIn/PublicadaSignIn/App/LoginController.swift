//
//  LoginController.swift
//  Publicada
//
//  Created by Joao Filipe Reis Justo da Silva on 18/09/24.
//

import Foundation
import CloudKit

struct User {
    var userId: String
    var name: String?
    var email: String?
    
    init(userId: String, name: String, email: String) {
        self.userId = userId
        self.name = name
        self.email = email
    }
}

extension User{
    // Converte um objeto do tipo record em uma instância do tipo User
    init?(record: CKRecord) {
        let userId: String = record.recordID.recordName
        let name: String? = record["name"] as? String
        let email: String? = record["email"] as? String
        
        self.userId = userId
        self.name = name
        self.email = email
    }
}

extension User {
    // Converte o objeto User em um objeto do tipo CKRecord,
    // este objeto CKRecord é usado para salvar dados no container do CloudKit
    var record: CKRecord {
        let recordId = CKRecord.ID(recordName: userId)
        let record = CKRecord(recordType: "User", recordID: recordId)
        
        record["name"] = name
        record["email"] = email
        
        return record
    }
}


class LoginController: ObservableObject {
    @Published var currentUser: User?
    
    let container: CKContainer = CKContainer(identifier: "iCloud.br.ufpe.cin.jfrjs.PublicadaSignIn")
    let database: CKDatabase
    
    
    init() {
        self.database = self.container.publicCloudDatabase
    }
    
    
    @MainActor
    func manageSignIn(userIndentifier: String, name: String, email: String) async throws {
        // Tenta obetr um usuário com base no user identifier do container
        if let registeredUser = try await getUser(userIdentifier: userIndentifier) {
            // Caso consiga, loga o usuário
            logUser(registeredUser)
        } else {
            // Caso não, registra o novo usuário
            try await registerUser(userIndentifier: userIndentifier, name: name, email: email)
        }
    }
    
    @MainActor
    func updateUserInfo(name: String, email: String) async throws {
        // Obtém o record ID do usuário
        let recordID = CKRecord.ID(recordName: currentUser!.userId)
        
        // Obtém o record do usuário
        let record = try await database.record(for: recordID)
        
        // Atualiza os campos do record
        if !name.isEmpty {record["name"] = name}
        if !email.isEmpty {record["email"] = email}
        
        // Salva as mudanças no container
        try await database.save(record)
        
        print("Dados atualizados:  nome (\(name)) - email (\(email))")
        
        try await updateCurrentUser()
    }
    
    func deleteUser() async throws {
        let recordID = CKRecord.ID(recordName: currentUser!.userId) // Obtém o record ID do usuário
        try await database.deleteRecord(withID: recordID) // Deleta o record com o ID
        
        print("Usuário deletado")
    }
    
    private func updateCurrentUser () async throws {
        // Obtém o record ID do usuário
        let recordID = CKRecord.ID(recordName: currentUser!.userId)
        
        // Obtém o record do usuário
        let record = try await database.record(for: recordID)
        
        // Atualiza o usuário atual
        let updatedUser = User(record: record)
        self.currentUser = updatedUser
        
        print("Usuário atual atualizado")
    }
    
    private func logUser(_ user: User) {
        self.currentUser = user // Estabelece o usuário atual
        print("User logado: \(currentUser?.name ?? "Sem nome") - \(currentUser?.email ?? "Sem email")")
    }
    
    
    private func registerUser(userIndentifier: String, name: String, email: String) async throws {
        let newUser = User(userId: userIndentifier, name: name, email: email) // Instancia um objeto usuário
        try await database.save(newUser.record) // Salva no container o objeto instanciado
        logUser(newUser)
    }
    
    
    private func getUser(userIdentifier: String) async throws -> User? {
        // Inicializa a variável de retorno
        var user: User?
        
        // Obtém o RecordID do usuário
        let recordID = CKRecord.ID(recordName: userIdentifier)
        
        do {
            
            // Tenta obter o record através do RecordID
            let record = try await database.record(for: recordID)
            user = User(record: record)
            
        } catch let error as CKError {
            // Caso o erro capturado seja um unknownItem (item desconhecido),
            // não fazemos nada, o item simplesmente não está no container
            if error.code != .unknownItem {
                // Caso seja um erro diferente de unknownItem, devemos tratá-lo
                throw error
            }
        }
        
        // Retorna o usuário
        return user
    }
}
