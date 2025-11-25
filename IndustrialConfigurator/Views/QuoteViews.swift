import SwiftUI

// MARK: - Quote Generation View
struct QuoteGenerationView: View {
    @ObservedObject var viewModel: ConfiguratorViewModel
    @EnvironmentObject var userSession: UserSession
    @Binding var isPresented: Bool
    @State private var notes: String = ""
    @State private var showingSuccess = false
    @State private var generatedQuote: Quote?

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Customer Information")) {
                    if let customer = userSession.currentUser?.customerInfo {
                        InfoRow(label: "Company", value: customer.companyName)
                        InfoRow(label: "Contact", value: customer.contactName)
                        InfoRow(label: "Email", value: customer.email)
                        if let phone = customer.phone {
                            InfoRow(label: "Phone", value: phone)
                        }
                    }
                }

                Section(header: Text("Configuration Summary")) {
                    ForEach(viewModel.selectedComponents) { component in
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(component.name)
                                    .font(.subheadline)
                                Text(component.category.displayName)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                            Text(formatPrice(component.basePrice))
                                .font(.subheadline)
                        }
                    }
                }

                if let priceCalc = viewModel.priceCalculation {
                    Section(header: Text("Price Breakdown")) {
                        InfoRow(label: "Subtotal", value: formatPrice(priceCalc.subtotal))

                        ForEach(Array(priceCalc.discounts.keys.sorted()), id: \.self) { key in
                            if let discount = priceCalc.discounts[key] {
                                HStack {
                                    Text(key)
                                        .foregroundColor(.green)
                                    Spacer()
                                    Text("-\(formatPrice(discount))")
                                        .foregroundColor(.green)
                                }
                            }
                        }

                        InfoRow(label: "Tax", value: formatPrice(priceCalc.taxAmount))

                        HStack {
                            Text("Total")
                                .fontWeight(.bold)
                            Spacer()
                            Text(formatPrice(priceCalc.total))
                                .fontWeight(.bold)
                                .foregroundColor(.blue)
                        }
                    }
                }

                Section(header: Text("Additional Notes")) {
                    TextEditor(text: $notes)
                        .frame(minHeight: 100)
                }

                Section {
                    Button(action: generateQuote) {
                        HStack {
                            Spacer()
                            Text("Generate Quote")
                                .fontWeight(.semibold)
                            Spacer()
                        }
                    }
                }
            }
            .navigationTitle("Generate Quote")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        isPresented = false
                    }
                }
            }
            .alert("Quote Generated", isPresented: $showingSuccess) {
                Button("View Quote") {
                    isPresented = false
                }
                Button("OK") {
                    isPresented = false
                }
            } message: {
                if let quote = generatedQuote {
                    Text("Quote \(quote.quoteNumber) has been saved to your account.")
                }
            }
        }
    }

    private func generateQuote() {
        guard let customerInfo = userSession.currentUser?.customerInfo else {
            return
        }

        let quote = viewModel.generateQuote(
            customerInfo: customerInfo,
            notes: notes.isEmpty ? nil : notes
        )

        userSession.saveQuote(quote)
        generatedQuote = quote
        showingSuccess = true
    }

    private func formatPrice(_ price: Decimal) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        return formatter.string(from: price as NSDecimalNumber) ?? "$0.00"
    }
}

// MARK: - Info Row
struct InfoRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label)
            Spacer()
            Text(value)
                .foregroundColor(.secondary)
        }
    }
}

// MARK: - Quote Detail View
struct QuoteDetailView: View {
    let quote: Quote
    @State private var showingShareSheet = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(quote.quoteNumber)
                            .font(.title)
                            .fontWeight(.bold)
                        Spacer()
                        StatusBadge(status: quote.status)
                    }

                    Text("Created: \(quote.createdDate.formatted(date: .long, time: .omitted))")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Text("Valid Until: \(quote.validUntilDate.formatted(date: .long, time: .omitted))")
                        .font(.caption)
                        .foregroundColor(quote.isExpired ? .red : .secondary)
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(12)

                // Customer Info
                VStack(alignment: .leading, spacing: 12) {
                    Text("Customer Information")
                        .font(.headline)

                    VStack(alignment: .leading, spacing: 8) {
                        DetailRow(label: "Company", value: quote.customerInfo.companyName)
                        DetailRow(label: "Contact", value: quote.customerInfo.contactName)
                        DetailRow(label: "Email", value: quote.customerInfo.email)
                        if let phone = quote.customerInfo.phone {
                            DetailRow(label: "Phone", value: phone)
                        }
                    }
                    .padding()
                    .background(Color(UIColor.systemBackground))
                    .cornerRadius(8)
                }

                // Bill of Materials
                VStack(alignment: .leading, spacing: 12) {
                    Text("Bill of Materials")
                        .font(.headline)

                    ForEach(quote.billOfMaterials.lineItems) { item in
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(item.component.name)
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                    Text(item.component.category.displayName)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                Spacer()
                                VStack(alignment: .trailing, spacing: 4) {
                                    Text("Qty: \(item.quantity)")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    Text(formatPrice(item.lineTotal))
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                }
                            }

                            if !item.component.specifications.isEmpty {
                                VStack(alignment: .leading, spacing: 4) {
                                    ForEach(Array(item.component.specifications.prefix(2)), id: \.key) { key, value in
                                        HStack {
                                            Text(key)
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                            Spacer()
                                            Text(value)
                                                .font(.caption)
                                        }
                                    }
                                }
                            }
                        }
                        .padding()
                        .background(Color(UIColor.systemBackground))
                        .cornerRadius(8)
                    }
                }

                // Price Summary
                VStack(alignment: .leading, spacing: 12) {
                    Text("Price Summary")
                        .font(.headline)

                    VStack(spacing: 8) {
                        DetailRow(label: "Subtotal", value: formatPrice(quote.billOfMaterials.subtotal))
                        DetailRow(label: "Tax", value: formatPrice(quote.billOfMaterials.tax))

                        Divider()

                        HStack {
                            Text("Total")
                                .font(.headline)
                            Spacer()
                            Text(formatPrice(quote.billOfMaterials.total))
                                .font(.headline)
                                .foregroundColor(.blue)
                        }
                    }
                    .padding()
                    .background(Color(UIColor.systemBackground))
                    .cornerRadius(8)
                }

                // Notes
                if let notes = quote.notes {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Notes")
                            .font(.headline)
                        Text(notes)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(Color(UIColor.systemBackground))
                    .cornerRadius(8)
                }

                // Terms and Conditions
                VStack(alignment: .leading, spacing: 8) {
                    Text("Terms and Conditions")
                        .font(.headline)
                    Text(quote.termsAndConditions)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(Color(UIColor.systemBackground))
                .cornerRadius(8)
            }
            .padding()
        }
        .navigationTitle("Quote Details")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { showingShareSheet = true }) {
                    Image(systemName: "square.and.arrow.up")
                }
            }
        }
    }

    private func formatPrice(_ price: Decimal) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        return formatter.string(from: price as NSDecimalNumber) ?? "$0.00"
    }
}

// MARK: - Detail Row
struct DetailRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label)
                .font(.subheadline)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .font(.subheadline)
        }
    }
}

// MARK: - Configuration Detail View
struct ConfigurationDetailView: View {
    let configuration: ProductConfiguration

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading, spacing: 8) {
                    Text(configuration.name)
                        .font(.title)
                        .fontWeight(.bold)

                    Text("Last Modified: \(configuration.lastModifiedDate.formatted(date: .long, time: .short))")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                VStack(alignment: .leading, spacing: 12) {
                    Text("Components (\(configuration.selectedComponents.count))")
                        .font(.headline)

                    ForEach(configuration.selectedComponents) { component in
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(component.name)
                                    .font(.subheadline)
                                Text(component.category.displayName)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                            Text(formatPrice(component.basePrice))
                                .font(.subheadline)
                        }
                        .padding()
                        .background(Color(UIColor.systemBackground))
                        .cornerRadius(8)
                    }
                }

                ProductPreview3DView(selectedComponents: configuration.selectedComponents)
                    .frame(height: 300)
            }
            .padding()
        }
        .navigationTitle("Configuration")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func formatPrice(_ price: Decimal) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        return formatter.string(from: price as NSDecimalNumber) ?? "$0.00"
    }
}
