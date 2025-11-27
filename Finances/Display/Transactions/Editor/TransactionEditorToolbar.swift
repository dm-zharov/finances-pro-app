//
//  TransactionEditorToolbar.swift
//  Finances
//
//  Created by Dmitriy Zharov on 08.10.2023.
//

import SwiftUI
import SwiftData

struct TransactionEditorToolbar: View {
    @Environment(\.calendar) var calendar
    
    @Binding var representation: TransactionRepresentation
    
    var body: some View {
        DateSelectorItem(selection: $representation.date)
            .tint(calendar.isDateInToday(representation.date) ? .primary : Color.accentColor)
        
        CategorySelectorItem(selection: $representation.categoryID)
            .tint(representation.categoryID == nil ? .primary : .accentColor)
        
        TagsSelectorItem(selection: $representation.tags)
            .tint(representation.tags.isEmpty ? .primary : .accentColor)
        
        NotesSelectorItem(selection: $representation.notes)
            .tint(representation.notes.isEmpty ? .primary : .accentColor)
    }
}
