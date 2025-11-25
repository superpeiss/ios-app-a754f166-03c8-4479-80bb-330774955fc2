import Foundation
import Combine

// MARK: - User Session
class UserSession: ObservableObject {
    @Published var currentUser: User?
    @Published var savedConfigurations: [ProductConfiguration] = []
    @Published var savedQuotes: [Quote] = []
    @Published var isLoggedIn: Bool = false

    init() {
        // Load saved data
        loadSavedData()
    }

    func login(user: User) {
        self.currentUser = user
        self.isLoggedIn = true
        loadSavedData()
    }

    func logout() {
        self.currentUser = nil
        self.isLoggedIn = false
        self.savedConfigurations = []
        self.savedQuotes = []
    }

    func saveConfiguration(_ configuration: ProductConfiguration) {
        if let index = savedConfigurations.firstIndex(where: { $0.id == configuration.id }) {
            savedConfigurations[index] = configuration
        } else {
            savedConfigurations.append(configuration)
        }
        persistData()
    }

    func saveQuote(_ quote: Quote) {
        if let index = savedQuotes.firstIndex(where: { $0.id == quote.id }) {
            savedQuotes[index] = quote
        } else {
            savedQuotes.append(quote)
        }
        persistData()
    }

    func deleteConfiguration(_ configuration: ProductConfiguration) {
        savedConfigurations.removeAll { $0.id == configuration.id }
        persistData()
    }

    func deleteQuote(_ quote: Quote) {
        savedQuotes.removeAll { $0.id == quote.id }
        persistData()
    }

    private func loadSavedData() {
        // In a production app, this would load from a database or API
        // For now, load from UserDefaults
        if let configData = UserDefaults.standard.data(forKey: "savedConfigurations") {
            if let configs = try? JSONDecoder().decode([ProductConfiguration].self, from: configData) {
                self.savedConfigurations = configs
            }
        }

        if let quotesData = UserDefaults.standard.data(forKey: "savedQuotes") {
            if let quotes = try? JSONDecoder().decode([Quote].self, from: quotesData) {
                self.savedQuotes = quotes
            }
        }
    }

    private func persistData() {
        if let configData = try? JSONEncoder().encode(savedConfigurations) {
            UserDefaults.standard.set(configData, forKey: "savedConfigurations")
        }

        if let quotesData = try? JSONEncoder().encode(savedQuotes) {
            UserDefaults.standard.set(quotesData, forKey: "savedQuotes")
        }
    }
}

// MARK: - User
struct User: Codable {
    let id: String
    var username: String
    var email: String
    var customerInfo: CustomerInfo

    init(id: String = UUID().uuidString,
         username: String,
         email: String,
         customerInfo: CustomerInfo) {
        self.id = id
        self.username = username
        self.email = email
        self.customerInfo = customerInfo
    }
}
