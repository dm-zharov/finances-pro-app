//
//  TransactionType.swift
//  Finances
//
//  Created by Dmitriy Zharov on 05.04.2024.
//

import Foundation
import FinanceKit

public enum TransactionType: Int16, Codable, CaseIterable, Sendable {

    /// The transaction's category doesn't map to a known value.
    case unknown

    /// A credit or debit adjustment transaction.
    case adjustment

    /// An ATM  transaction.
    case atm

    /// A bill payment, usually carried out through an eBill or eCheck system.
    case billPayment

    /// A check  payment.
    case check

    /// A deposit of money by a payer into a payee's bank account.
    case deposit

    /// A deposit of money by a payer directly into a payee's bank account.
    case directDeposit

    /// A distribution of a company's earnings to its shareholders.
    case dividend

    /// A fee or charge levied by the account provider.
    ///
    /// For example, an overdraft fee or foreign currency commission.
    case fee

    /// A credit or debit due to interest earned or incurred.
    case interest

    /// A Point of Sales transaction.
    case pointOfSale

    /// A transfer between accounts.
    case transfer

    /// An automatic or recurring withdrawal of funds by another party.
    case withdrawal

    /// A regular payment of a fixed amount that's paid on a specified date.
    case standingOrder

    /// A payment to a third party on agreed dates, typically in order to pay bills.
    case directDebit

    /// A loan drawdown or repayment.
    case loan

    /// A refund.
    case refund
}
