//
//  SymbolName.swift
//  Finances
//
//  Created by Dmitriy Zharov on 17.12.2023.
//

import SwiftUI
import AppUI
import FoundationExtension

public struct SymbolName: Hashable, RawRepresentable, Sendable {
    public var rawValue: String
    
    public init(rawValue: String) {
        self.rawValue = rawValue
    }
}

extension SymbolName: ExpressibleByStringLiteral {
    public init(stringLiteral value: String) {
        self.init(rawValue: value)
    }
}

extension SymbolName: DefaultValueProvidable {
    public static let defaultValue: SymbolName = SymbolName(rawValue: "questionmark")
}

extension SymbolName {
    enum Category: SymbolName, CaseIterable {
        // Communication
        case antenna = "antenna.radiowaves.left.and.right"
        case phone
        case envelope
        case doc
        case paperplane
        case archivebox
        
        // Transport
        case airplane
        case car
        case fuelpump
        case parkingsign
        case bicycle
        case walk = "figure.walk"
        case tram
        case sailboat
        
        // Objects
        case bookmark
        case book
        case bookClosed = "book.closed"
        case graduationcap
        
        // Government
        case building = "building.columns"
        case storefront
        case shippingbox
        case purchased
        case clock
        case timer
        case square
        case triangle
        
        // Creativity
        case camera
        case photo
        
        // Food
        case forkKnife = "fork.knife"
        case cart
        
        // Gifts
        case person
        case person2 = "person.2"
        case heart
        case gift
        
        // Journey
        case pin
        case mappin
        case houseLodge = "house.lodge"
        case mountain = "mountain.2"
        case tent
        case flame
        case leaf
        
        // Health
        case microbe
        case cross
        case stethoscope
        case pills
        case scissors
        
        // Pet
        case bird
        case fish
        case cat
        case dog
        case pawprint
        
        // Home
        case house
        case hammer
        case lock
        case bedDouble = "bed.double"
        case toilet
        case lightbulb
        
        // Entertainment
        case star
        case play = "play.rectangle.on.rectangle"
        case popcorn
        case film
        case theatermasks
        
        // Clothes
        case bag
        case handbag
        case backpack
        case tshirt
        case shoe
        
        // Sport
        case figureRun = "figure.run"
        case football
        case basketball
        case cricketBall = "cricket.ball"
        case trophy
        case flag = "flag.2.crossed"
        
        // Arrows
        case arrowUp = "arrow.up"
        case arrowDown = "arrow.down"
        case arrowLeft = "arrow.left"
        case arrowRight = "arrow.right"
        case arrowLeftRight = "arrow.left.arrow.right"
        case arrowCirclepath = "arrow.triangle.2.circlepath"
        case arrowClockwise = "arrow.clockwise"
        case arrowCounterclockwise = "arrow.counterclockwise"
        
        // Weather
        case sun = "sun.max"
        case moon
        case cloud
        case smoke = "smoke"
        case snowflake
        case tornado
    }
    
    static func category(_ value: Category) -> SymbolName {
        value.rawValue
    }
}

extension SymbolName {
    enum Menu: SymbolName {
        case chevronUp = "chevron.up"
        case chevronDown = "chevron.down"
    }
    
    static func menu(_ value: Menu) -> SymbolName {
        value.rawValue
    }
}

extension SymbolName {
    enum Toolbar: SymbolName {
        case paperclip = "paperclip.badge.ellipsis"
        case storefront = "storefront"
        case calendar = "calendar.badge.clock"
        case number = "number"
        case note = "note.text"
    }
    
    static func toolbar(_ value: Toolbar) -> SymbolName {
        value.rawValue
    }
}

extension SymbolName {
    enum Setting: SymbolName {
        case asset = "creditcard"
        case star = "star"
        
        case gearshape = "gearshape"
        case currency = "dollarsign"
        case paperclip = "paperclip"
        case storefront = "storefront"
        case number = "number"
        
        case bell = "bell"
        case lock = "lock"
        case lightbulb = "lightbulb"
        case icloud = "icloud"
        
        case transfer = "arrow.down.left.arrow.up.right"
        case externaldrive = "externaldrive.fill"
        
        case heart = "heart"
        case envelope = "envelope"
        case curlybraces = "curlybraces"
        
        case house = "house"
        case date = "calendar"
        case `repeat` = "repeat"
        
        case pencil = "pencil"
    }
    
    static func setting(_ value: Setting) -> SymbolName {
        value.rawValue
    }
}
