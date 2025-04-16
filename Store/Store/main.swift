//
//  main.swift
//  Store
//
//  Created by Ted Neward on 2/29/24.
//

import Foundation

protocol SKU {
    var name: String { get }
    func price() -> Int
}

protocol Taxable {
    func tax() -> Int
}

class Coupon {
    let targetItemName: String

    init(for itemName: String) {
        self.targetItemName = itemName
    }
}

class Item: SKU, Taxable {
    let name: String
    private let priceEach: Int
    let isEdible: Bool
    
    init (name: String, priceEach: Int, isEdible: Bool = true) {
        self.name = name
        self.priceEach = priceEach
        self.isEdible = isEdible
    }
    
    func price() -> Int {
        return priceEach
    }
    
    // decision: rounds to nearest Int
    func tax() -> Int {
        if isEdible {
            return 0
        }
        let taxRate = 0.1
        let rawTax = Double(priceEach) * taxRate
        return Int(rawTax.rounded())
    }
    
}

class Receipt {
    private var scannedItems: [SKU] = []
    private var coupons: [Coupon] = []
    
    func addItem(_ item: SKU) {
        scannedItems.append(item)
    }
    
    func addCoupon(_ coupon: Coupon) {
        coupons.append(coupon)
    }
    
    func items() -> [SKU] {
        return scannedItems
    }
    
    func totalTax() -> Int {
        var tax = 0
        var usedCoupons: [Int] = []

        for item in scannedItems {
            let price = discountedPrice(for: item, used: &usedCoupons)
            if let it = item as? Item {
                if !it.isEdible {
                    let rawTax = Double(price) * 0.1
                    tax += Int(rawTax.rounded())
                }
            }
        }

        return tax
    }
    
    func total() -> Int {
        var subtotal = 0
        var usedCoupons: [Int] = []

        for item in scannedItems {
            let price = discountedPrice(for: item, used: &usedCoupons)
            subtotal += price
        }

        return subtotal + totalTax()
    }
    
    func output() -> String {
        var result = "Receipt:\n"
        var subtotal = 0
        var usedCoupons: [Int] = []

        for item in scannedItems {
            let price = discountedPrice(for: item, used: &usedCoupons)
            subtotal += price
            let dollar = Double(price) / 100.0
            result += "\(item.name): $\(String(format: "%.2f", dollar))\n"
        }

        let tax = totalTax()
        let total = subtotal + tax

        result += "------------------\n"
        if tax > 0 {
            result += String(format: "SUBTOTAL: $%.2f\n", Double(subtotal) / 100.0)
            result += String(format: "TAX: $%.2f\n", Double(tax) / 100.0)
        }
        result += String(format: "TOTAL: $%.2f", Double(total) / 100.0)

        return result
    }
    
    private func discountedPrice(for item: SKU, used: inout [Int]) -> Int {
        for i in 0..<coupons.count {
            if !used.contains(i) && coupons[i].targetItemName == item.name {
                used.append(i)
                return Int(Double(item.price()) * 0.85)
            }
        }
        return item.price()
    }
}

class Register {
    private var receipt: Receipt
    
    init() {
        self.receipt = Receipt()
    }
    
    func scan(_ item: SKU) {
        receipt.addItem(item)
    }
    
    func scanCoupon(_ coupon: Coupon) {
        receipt.addCoupon(coupon)
    }
    
    func subtotal() -> Int {
        return receipt.total()
    }
    
    func total() -> Receipt {
        let completed = receipt
        receipt = Receipt()
        return completed
    }
}

class Store {
    let version = "0.1"
    func helloWorld() -> String {
        return "Hello world"
    }
}
