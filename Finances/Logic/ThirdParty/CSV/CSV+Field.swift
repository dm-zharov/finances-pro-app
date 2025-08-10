//
//  Statement+Field.swift
//  Finances
//
//  Created by Dmitriy Zharov on 30.11.2023.
//

import Foundation
import SwiftCSV
import OrderedCollections
import AppUI

class Statement: Identifiable {
    let id: UUID = UUID()

    var assets: [AssetRepresentation] = []
    var categories: [CategoryRepresentation] = []
    var transactions: [TransactionRepresentation] = []
}

extension Statement {
    enum Field: String, CaseIterable, Codable, CustomLocalizedStringResourceConvertible {
        case date
        case category
        case payee
        case amount
        case currency
        case notes
        case tags
        case account
        case id
        case sign
        
        var localizedStringResource: LocalizedStringResource {
            switch self {
            case .date:
                "Date"
            case .category:
                "Category"
            case .payee:
                "Payee"
            case .amount:
                "Amount"
            case .currency:
                "Currency"
            case .notes:
                "Note"
            case .tags:
                "Tags"
            case .account:
                "Account"
            case .id:
                "Transaction ID"
            case .sign:
                "Amount Sign"
            }
        }
        
        var symbolName: SymbolName {
            switch self {
            case .date:
                SymbolName.Setting.date.rawValue
            case .category:
                SymbolName.Setting.paperclip.rawValue
            case .payee:
                SymbolName.Setting.storefront.rawValue
            case .amount:
                SymbolName(rawValue: "textformat.12")
            case .currency:
                SymbolName.Setting.currency.rawValue
            case .notes:
                SymbolName.Toolbar.note.rawValue
            case .tags:
                SymbolName.Toolbar.number.rawValue
            case .account:
                SymbolName.Setting.asset.rawValue
            case .id:
                SymbolName(rawValue: "1.magnifyingglass")
            case .sign:
                SymbolName(rawValue: "plusminus")
            }
        }
        
        static let grouped: [FieldGroup] = [
            FieldGroup(items: [.category, .payee]),
            FieldGroup(items: [.account, .amount, .currency]),
            FieldGroup(items: [.date, .tags, .notes]),
            FieldGroup(header: "Extra", items: [.id, .sign])
        ]
    }
    
    struct FieldGroup: Hashable {
        let header: String?
        let items: [Field]
        
        init(header: String? = nil, items: [Field]) {
            self.header = header
            self.items = items
        }
    }
}
