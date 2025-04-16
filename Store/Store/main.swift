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

class Item: SKU, Taxable {
    let name: String
    private let priceEach: Int
    private let isEdible: Bool
    
    init (name: String, priceEach: Int, isEdible: Bool = true) {
        self.name = name
        self.priceEach = priceEach
        self.isEdible = isEdible
    }
    
    func price() -> Int {
        return priceEach
    }
    
    // rounds to nearest Int
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
    
    func addItem(_ item: SKU) {
        scannedItems.append(item)
    }
    
    func items() -> [SKU] {
        return scannedItems
    }
    
    func output() -> String {
        var result = "Receipt:\n"
        
        for item in scannedItems {
            let dollar = Double(item.price()) / 100.0
            result += "\(item.name): $\(String(format: "%.2f", dollar))\n"
        }
        
        let tax = totalTax()
        if tax > 0 {
            let subtotal = scannedItems.reduce(0) { $0 + $1.price() }
            let subtotalDollars = Double(subtotal) / 100.0
            let taxDollars = Double(tax) / 100.0
            let totalDollars = Double(subtotal + tax) / 100.0
            
            result += "------------------\n"
            result += String(format: "SUBTOTAL: $%.2f\n", subtotalDollars)
            result += String(format: "TAX: $%.2f\n", taxDollars)
            result += String(format: "TOTAL: $%.2f", totalDollars)
        } else {
            let totalDollars = Double(total()) / 100.0
            result += "------------------\n"
            result += String(format: "TOTAL: $%.2f", totalDollars)
        }
        
        
        return result
    }
    
    func totalTax() -> Int {
        return scannedItems
            .compactMap { $0 as? Taxable }
            .reduce(0) { $0 + $1.tax() }
    }
    
    func total() -> Int {
        let num = scannedItems.reduce(0) { $0 + $1.price() }
        return num + totalTax()
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
