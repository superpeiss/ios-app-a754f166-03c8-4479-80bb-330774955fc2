import Foundation

// MARK: - BOM Line Item
struct BOMLineItem: Identifiable, Codable {
    let id: String
    let component: Component
    let quantity: Int
    let unitPrice: Decimal
    let lineTotal: Decimal
    let discount: Decimal?
    let notes: String?

    init(component: Component, quantity: Int = 1, discount: Decimal? = nil, notes: String? = nil) {
        self.id = UUID().uuidString
        self.component = component
        self.quantity = quantity
        self.unitPrice = component.basePrice

        let subtotal = component.basePrice * Decimal(quantity)
        if let discount = discount {
            self.lineTotal = subtotal - discount
        } else {
            self.lineTotal = subtotal
        }

        self.discount = discount
        self.notes = notes
    }
}

// MARK: - Bill of Materials
struct BillOfMaterials: Identifiable, Codable {
    let id: String
    let configurationId: String
    var lineItems: [BOMLineItem]
    let createdDate: Date
    var subtotal: Decimal
    var tax: Decimal
    var total: Decimal

    init(configurationId: String, lineItems: [BOMLineItem], taxRate: Decimal = 0.0) {
        self.id = UUID().uuidString
        self.configurationId = configurationId
        self.lineItems = lineItems
        self.createdDate = Date()

        self.subtotal = lineItems.reduce(Decimal(0)) { $0 + $1.lineTotal }
        self.tax = self.subtotal * taxRate
        self.total = self.subtotal + self.tax
    }

    mutating func recalculate(taxRate: Decimal = 0.0) {
        self.subtotal = lineItems.reduce(Decimal(0)) { $0 + $1.lineTotal }
        self.tax = self.subtotal * taxRate
        self.total = self.subtotal + self.tax
    }
}

// MARK: - Pricing Rule
struct PricingRule: Codable {
    let id: String
    let name: String
    let ruleType: PricingRuleType
    let threshold: Decimal?
    let discountPercentage: Decimal?
    let discountAmount: Decimal?
    let applicableComponentCategories: [ComponentCategory]?

    enum PricingRuleType: String, Codable {
        case volumeDiscount = "Volume Discount"
        case bundleDiscount = "Bundle Discount"
        case categoryDiscount = "Category Discount"
        case customDiscount = "Custom Discount"
    }
}

// MARK: - Price Calculation Result
struct PriceCalculationResult {
    let subtotal: Decimal
    let discounts: [String: Decimal]
    let taxAmount: Decimal
    let total: Decimal
    let appliedRules: [PricingRule]

    var totalDiscount: Decimal {
        discounts.values.reduce(0, +)
    }
}
