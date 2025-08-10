//
//  API+Transactions.swift
//  Finances
//
//  Created by Dmitriy Zharov on 21.12.2022.
//

import Combine
import CKNetworking

// MARK: - Get All Transactions
extension API {
    enum GetTransactions {
        struct Query: Encodable {
            /// Filter by tag. Only accepts IDs, not names.
            var tagId: LMTag.ID? = nil
            /// Filter by recurring expense
            var recurringId: UInt64? = nil
            /// Filter by Plaid account
            var plaidAccountId: UInt64? = nil
            /// Filter by category. Will also match category groups.
            var categoryId: LMCategory.ID? = nil
            /// Filter by asset
            var assetId: UInt64? = nil
            /// Filter by group_id (if the transaction is part of a specific group)
            var groupId: UInt64? = nil
            /// Filter by group (returns transaction groups)
            var isGroup: Bool? = nil
            /// Filter by status (Can be cleared or uncleared. For recurring transactions, use recurring)
            var status: String? = nil
            /// Sets the offset for the records returned
            var offset: Int? = nil
            /// Sets the maximum number of records to return. Note: The server will not respond with any indication that there are more records to be returned. Please check the response length to determine if you should make another call with an offset to fetch more transactions.
            var limit: Int? = nil
            /// Denotes the beginning of the time period to fetch transactions for. Defaults to beginning of current month. Required if end_date exists. Format: YYYY-MM-DD.
            var startDate: String? = nil
            /// Denotes the end of the time period you'd like to get transactions for. Defaults to end of current month. Required if start_date exists. Format: YYYY-MM-DD.
            var endDate: String? = nil
            /// Pass in true if you’d like expenses to be returned as negative amounts and credits as positive amounts.
            var debitAsNegative: String /* Bool */ = "true"
            /// Pass in true if you’d like to include imported transactions with a pending status.
            var pending: String /* Bool */ = "false"
        }
        
        struct Response: Decodable {
            let transactions: [LMTransaction]
        }
    }
    
    /// Use this endpoint to retrieve all transactions between a date range.
    /// - Returns: List of Transaction objects. If no query parameters are set, this endpoint will return transactions for the current calendar month (see start_date and end_date)
    func getTransactions(query: GetTransactions.Query = .init()) -> AnyPublisher<GetTransactions.Response, Error> {
        get("/transactions", params: query.asParams())
    }
}

// MARK: - Get Single Transaction
extension API {
    enum GetTransaction {
        struct Query: Encodable {
            /// Pass in true if you’d like expenses to be returned as negative amounts and credits as positive amounts.
            var debitAsNegative: Bool = false
        }
    }
    
    /// Use this endpoint to retrieve details about a specific transaction by ID.
    /// - Returns: Single Transaction object
    func getTransaction(with id: LMTransaction.ID, query: GetTransaction.Query = .init()) -> AnyPublisher<LMTransaction, Error> {
        get("/transactions/\(id))", params: query.asParams())
    }
}

// MARK: - Insert Transactions
extension API {
    enum InsertTransactions {
        struct Body: Encodable {
            struct Transaction: Encodable {
                /// Must be in ISO 8601 format (YYYY-MM-DD).
                var date: String
                /// Numeric value of amount. i.e. $4.25 should be denoted as 4.25.
                var amount: String // Possible -> Int
                /// Unique identifier for associated category_id. Category must be associated with the same account and must not be a category group.
                var categoryId: UInt64? = nil
                /// Max 140 characters
                var payee: String? = nil
                /// Three-letter lowercase currency code in ISO 4217 format. The code sent must exist in our database. Defaults to user account's primary currency.
                var currency: String? = nil
                /// Unique identifier for associated asset (manually-managed account). Asset must be associated with the same account.
                var assetId: UInt64? = nil
                /// Unique identifier for associated recurring expense. Recurring expense must be associated with the same account.
                var recurringId: UInt64? = nil
                /// Max 350 characters
                var notes: String? = nil
                /// Must be either cleared or uncleared. If recurring_id is provided, the status will automatically be set to recurring or recurring_suggested depending on the type of recurring_id. Defaults to uncleared.
                var status: String? = nil
                /// User-defined external ID for transaction. Max 75 characters. External IDs must be unique within the same asset_id.
                var externalId: String? = nil
                /// Passing in a string will attempt to match by string. If no matching tag name is found, a new tag will be created.
                /// Passing in a number will attempt to match by ID. If no matching tag ID is found, an error will be thrown.
                var tags: [String]? = nil // Possible -> [Int]
            }
            
            /// List of transactions to insert
            var transactions: [Transaction]
            /// If true, will apply account’s existing rules to the inserted transactions.
            var applyRules: Bool = false
            /// If true, the system will automatically dedupe based on transaction date, payee and amount. Note that deduping by external_id will occur regardless of this flag.
            var skipDuplicates: Bool = false
            /// If true, will check new transactions for occurrences of new monthly expenses.
            var checkForRecurring: Bool = false
            /// If true, will assume negative amount values denote expenses and positive amount values denote credits.
            var debitAsNegative: Bool = false
            /// If true, will skip updating balance if an asset_id is present for any of the transactions.
            var skipBalanceUpdate: Bool = true
        }
        
        struct Response: Decodable {
            let ids: [Int]
        }
    }
    
    /// Use this endpoint to insert many transactions at once.
    func insertTransaction(body: InsertTransactions.Body) -> AnyPublisher<InsertTransactions.Response, Error> {
        post("/transactions", data: body.asParams())
    }
}

// MARK: - Update Transaction
extension API {
    enum UpdateTransaction {
        struct Body: Encodable {
            struct Split: Encodable {
                /// Max 140 characters. Sets to original payee if none defined
                var payee: String? = nil
                /// Must be in ISO 8601 format (YYYY-MM-DD). Sets to original date if none defined
                var date: String? = nil
                /// Unique identifier for associated category_id. Category must be associated with the same account. Sets to original category if none defined
                var category_Id: UInt64? = nil
                /// Sets to original notes if none defined
                var notes: String?
                /// Individual amount of split. Currency will inherit from parent transaction. All amounts must sum up to parent transaction amount.
                var amount: String // Possible -> Int
            }
            
            struct Transaction: Encodable {
                /// Must be in ISO 8601 format (YYYY-MM-DD).
                var date: String
                /// You may only update this if this transaction was not created from an automatic import, i.e. if this transaction is not associated with a plaid_account_id
                var amount: String? = nil // Possible -> Int
                /// Unique identifier for associated category_id. Category must be associated with the same account and must not be a category group.
                var categoryId: UInt64? = nil
                /// Max 140 characters
                var payee: String? = nil
                /// You may only update this if this transaction was not created from an automatic import, i.e. if this transaction is not associated with a plaid_account_id. Defaults to user account's primary currency.
                var currency: String? = nil
                /// Unique identifier for associated asset (manually-managed account). Asset must be associated with the same account. You may only update this if this transaction was not created from an automatic import, i.e. if this transaction is not associated with a plaid_account_id
                var assetId: UInt64? = nil
                /// Unique identifier for associated recurring expense. Recurring expense must be associated with the same account.
                var recurringId: UInt64? = nil
                /// Max 350 characters
                var notes: String? = nil
                /// Must be either cleared or uncleared. Defaults to uncleared If recurring_id is provided, the status will automatically be set to recurring or recurring_suggested depending on the type of recurring_id. Defaults to uncleared.
                var status: String? = nil
                /// User-defined external ID for transaction. Max 75 characters. External IDs must be unique within the same asset_id. You may only update this if this transaction was not created from an automatic import, i.e. if this transaction is not associated with a plaid_account_id
                var externalId: String? = nil
                /// Input must be an array, or error will be thrown. Passing in a number will attempt to match by ID. If no matching tag ID is found, an error will be thrown. Passing in a string will attempt to match by string. If no matching tag name is found, a new tag will be created. Pass in null to remove all tags.
                var tags: [String]? = nil // Possible -> [Int]
            }
            
            /// Defines the split of a transaction. You may not split an already-split transaction, recurring transaction, or group transaction.
            var split: Split? = nil
            /// The transaction update object (see Update Transaction object below). Must include an id matching an existing transaction.
            var transaction: Transaction
            /// If true, will assume negative amount values denote expenses and positive amount values denote credits.
            var debit_as_negative: Bool = false
            /// If false, will skip updating balance if an asset_id is present for any of the transactions.
            var skip_balance_update: Bool = true
        }
        
        struct Response: Decodable {
            let updated: Bool
            let split: [LMTransaction.ID]
        }
    }
    
    func updateTransaction(with id: LMTransaction.ID, body: UpdateTransaction.Body) -> AnyPublisher<UpdateTransaction.Response, Error> {
        put("/transactions/\(id)", data: body.asParams())
    }
}

// MARK: - Unsplit Transactions
extension API { }

// MARK: - Create Transaction Group
extension API { }

// MARK: - Delete Transaction Group
extension API { }
