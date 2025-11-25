import SwiftUI

struct ContentView: View {
    @EnvironmentObject var userSession: UserSession
    @State private var showingLoginSheet = false

    var body: some View {
        NavigationView {
            if userSession.isLoggedIn {
                HomeView()
            } else {
                WelcomeView(showingLoginSheet: $showingLoginSheet)
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .sheet(isPresented: $showingLoginSheet) {
            LoginView(isPresented: $showingLoginSheet)
                .environmentObject(userSession)
        }
    }
}

// MARK: - Welcome View
struct WelcomeView: View {
    @Binding var showingLoginSheet: Bool

    var body: some View {
        VStack(spacing: 30) {
            Spacer()

            Image(systemName: "gearshape.2.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 120, height: 120)
                .foregroundColor(.blue)

            VStack(spacing: 10) {
                Text("Industrial Configurator")
                    .font(.system(size: 32, weight: .bold))

                Text("Configure your perfect industrial assembly")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }

            Spacer()

            Button(action: {
                showingLoginSheet = true
            }) {
                Text("Get Started")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(12)
            }
            .padding(.horizontal, 40)
            .padding(.bottom, 50)
        }
        .navigationTitle("")
        .navigationBarHidden(true)
    }
}

// MARK: - Login View
struct LoginView: View {
    @EnvironmentObject var userSession: UserSession
    @Binding var isPresented: Bool
    @State private var companyName = ""
    @State private var contactName = ""
    @State private var email = ""
    @State private var phone = ""

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Company Information")) {
                    TextField("Company Name", text: $companyName)
                    TextField("Contact Name", text: $contactName)
                }

                Section(header: Text("Contact Details")) {
                    TextField("Email", text: $email)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                    TextField("Phone", text: $phone)
                        .keyboardType(.phonePad)
                }

                Section {
                    Button(action: login) {
                        HStack {
                            Spacer()
                            Text("Continue")
                                .fontWeight(.semibold)
                            Spacer()
                        }
                    }
                    .disabled(!isFormValid)
                }
            }
            .navigationTitle("Account Setup")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        isPresented = false
                    }
                }
            }
        }
    }

    private var isFormValid: Bool {
        !companyName.isEmpty && !contactName.isEmpty && !email.isEmpty && email.contains("@")
    }

    private func login() {
        let customerInfo = CustomerInfo(
            companyName: companyName,
            contactName: contactName,
            email: email,
            phone: phone.isEmpty ? nil : phone
        )

        let user = User(
            username: contactName,
            email: email,
            customerInfo: customerInfo
        )

        userSession.login(user: user)
        isPresented = false
    }
}

// MARK: - Home View
struct HomeView: View {
    @EnvironmentObject var userSession: UserSession

    var body: some View {
        VStack(spacing: 0) {
            List {
                Section {
                    NavigationLink(destination: ConfiguratorMainView()) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                                .font(.title2)
                                .foregroundColor(.blue)
                            VStack(alignment: .leading, spacing: 4) {
                                Text("New Configuration")
                                    .font(.headline)
                                Text("Start a new product assembly")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding(.vertical, 8)
                    }
                }

                if !userSession.savedConfigurations.isEmpty {
                    Section(header: Text("Saved Configurations")) {
                        ForEach(userSession.savedConfigurations) { config in
                            NavigationLink(destination: ConfigurationDetailView(configuration: config)) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(config.name)
                                        .font(.headline)
                                    Text("\(config.selectedComponents.count) components")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                    }
                }

                if !userSession.savedQuotes.isEmpty {
                    Section(header: Text("Saved Quotes")) {
                        ForEach(userSession.savedQuotes) { quote in
                            NavigationLink(destination: QuoteDetailView(quote: quote)) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(quote.quoteNumber)
                                        .font(.headline)
                                    HStack {
                                        Text(quote.formattedTotal)
                                            .font(.subheadline)
                                            .foregroundColor(.blue)
                                        Spacer()
                                        StatusBadge(status: quote.status)
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .listStyle(InsetGroupedListStyle())
            .navigationTitle("Industrial Configurator")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button(action: { userSession.logout() }) {
                            Label("Logout", systemImage: "rectangle.portrait.and.arrow.right")
                        }
                    } label: {
                        Image(systemName: "person.circle")
                    }
                }
            }
        }
    }
}

// MARK: - Status Badge
struct StatusBadge: View {
    let status: QuoteStatus

    var body: some View {
        Text(status.rawValue)
            .font(.caption2)
            .fontWeight(.semibold)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(backgroundColor)
            .foregroundColor(.white)
            .cornerRadius(4)
    }

    private var backgroundColor: Color {
        switch status {
        case .draft: return .gray
        case .pending: return .orange
        case .approved: return .green
        case .rejected: return .red
        case .expired: return .purple
        }
    }
}

// MARK: - Previews
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(UserSession())
    }
}
