//
//  LMTransaction.swift
//  Finances
//
//  Created by Dmitriy Zharov on 27.09.2023.
//

import Foundation

struct LMTransaction: Decodable, Identifiable, Hashable {
    /// Unique identifier for transaction
    let id: UInt64
    /// Date of transaction in ISO 8601 format
    @StringRepresentation<Date>
    var date: String
    /// Name of payee If recurring_id is not null, this field will show the payee of associated recurring expense instead of the original transaction payee
    let payee: String?
    /// Amount of the transaction in numeric format to 4 decimal places
    @StringRepresentation<Double>
    var amount: String
    /// Three-letter lowercase currency code of the transaction in ISO 4217 format
    let currency: String
    /// User-entered transaction notes If recurring_id is not null, this field will be description of associated recurring expense
    let notes: String?
    /// Unique identifier of associated category
    /// - SeeAlso: Categories
    let categoryId: UInt64?
    /// Unique identifier of associated manually-managed account
    /// - SeeAlso: Assets
    /// - Note: plaid_account_id and asset_id cannot both exist for a transaction
    let assetId: UInt64?
    /// Unique identifier of associated Plaid account
    /// - SeeAlso: Plaid Accounts
    /// - Note: plaid_account_id and asset_id cannot both exist for a transaction
    let plaidAccountId: UInt64?
    /// User intervention is required to change this to recurring.
    let status: Status
    /// Exists if this is a split transaction. Denotes the transaction ID of the original transaction. Note that the parent transaction is not returned in this call.
    let parentId: UInt64?
    /// True if this transaction represents a group of transactions. If so, amount and currency represent the totalled amount of transactions bearing this transaction’s id as their group_id. Amount is calculated based on the user’s primary currency.
    let isGroup: Bool
    /// Exists if this transaction is part of a group. Denotes the parent’s transaction ID
    let groupId: UInt64?
    /// Array of Tag objects
    let tags: [LMTag]?
    /// User-defined external ID for any manually-entered or imported transaction. External ID cannot be accessed or changed for Plaid-imported transactions. External ID must be unique by asset_id. Max 75 characters.
    let externalId: String?
    /// The transactions original name before any payee name updates. For synced transactions, this is the raw original payee name from your bank.
    let originalName: String?
    
    // MARK: - Synced investment transactions only
    
    /// The transaction type as set by Plaid for investment transactions. Possible values include: buy, sell, cash, transfer and more
    let type: String?
    /// The transaction type as set by Plaid for investment transactions. Possible values include: management fee, withdrawal, dividend, deposit and more
    let subtype: String?
    /// The fees as set by Plaid for investment transactions.
    let fees: String?
    /// The price as set by Plaid for investment transactions.
    let price: String?
    /// The quantity as set by Plaid for investment transactions.
    let quantity: String?
}

extension LMTransaction {
    enum Status: String, Decodable {
        /// User has reviewed the transaction
        case cleared
        /// User has not yet reviewed the transaction
        case uncleared
        /// Transaction is linked to a recurring expense
        case recurring
        /// Transaction is listed as a suggested transaction for an existing recurring expense.
        case recurringSuggested
        /// Imported transaction is marked as pending. This should be a temporary state.
        case pending
    }
}
