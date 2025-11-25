import Foundation

// MARK: - Quote Status
enum QuoteStatus: String, Codable {
    case draft = "Draft"
    case pending = "Pending"
    case approved = "Approved"
    case rejected = "Rejected"
    case expired = "Expired"
}

// MARK: - Quote
struct Quote: Identifiable, Codable {
    let id: String
    let quoteNumber: String
    let configuration: ProductConfiguration
    let billOfMaterials: BillOfMaterials
    let customerInfo: CustomerInfo
    var status: QuoteStatus
    let createdDate: Date
    let validUntilDate: Date
    var approvedDate: Date?
    let notes: String?
    let termsAndConditions: String

    init(configuration: ProductConfiguration,
         billOfMaterials: BillOfMaterials,
         customerInfo: CustomerInfo,
         status: QuoteStatus = .draft,
         validityDays: Int = 30,
         notes: String? = nil) {
        self.id = UUID().uuidString
        self.quoteNumber = "QT-\(Date().timeIntervalSince1970.description.prefix(10))"
        self.configuration = configuration
        self.billOfMaterials = billOfMaterials
        self.customerInfo = customerInfo
        self.status = status
        self.createdDate = Date()
        self.validUntilDate = Calendar.current.date(byAdding: .day, value: validityDays, to: Date()) ?? Date()
        self.notes = notes
        self.termsAndConditions = """
        1. Prices are valid until \(validUntilDate.formatted(date: .long, time: .omitted))
        2. All components are subject to availability
        3. Lead time: 4-6 weeks from order confirmation
        4. Payment terms: Net 30 days
        5. Warranty: 1 year from delivery date
        """
    }

    var isExpired: Bool {
        return Date() > validUntilDate
    }

    var formattedTotal: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        return formatter.string(from: billOfMaterials.total as NSDecimalNumber) ?? "$0.00"
    }
}

// MARK: - Customer Info
struct CustomerInfo: Codable {
    let id: String
    var companyName: String
    var contactName: String
    var email: String
    var phone: String?
    var address: Address?

    init(id: String = UUID().uuidString,
         companyName: String,
         contactName: String,
         email: String,
         phone: String? = nil,
         address: Address? = nil) {
        self.id = id
        self.companyName = companyName
        self.contactName = contactName
        self.email = email
        self.phone = phone
        self.address = address
    }
}

// MARK: - Address
struct Address: Codable {
    var street: String
    var city: String
    var state: String
    var zipCode: String
    var country: String

    var formattedAddress: String {
        return "\(street)\n\(city), \(state) \(zipCode)\n\(country)"
    }
}
