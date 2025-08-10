//
//  CategoryEditorView.swift
//  Finances
//
//  Created by Dmitriy Zharov on 11.10.2023.
//

import SwiftUI
import SwiftData
import AppUI
import AppIntents
import HapticFeedback
#if os(iOS)
import SwiftUIIntrospect
#endif

struct CategoryEditorView: View {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @Query private var categoryGroups: [CategoryGroup]
    
    // MARK: - Data
    
    let category: Category?
    let showsCancel: Bool
    
    // MARK: - State
    
    @State private var representation = CategoryRepresentation()
    
    @State private var showPicker: Bool = false
    @FocusState private var isFocused: Bool
    
    private var editorTitle: String {
        category == nil ? String(localized: "Add Category") : String(localized: "Edit Category")
    }
    
    private let columns = [GridItem(.adaptive(minimum: 16, maximum: 16), spacing: 8.0)]
    
    var body: some View {
#if DEBUG
        let _ = Self._printChanges()
#endif
        VStack {
            #if os(iOS)
            list
            #else
            form
            #endif
        }
        .focusedValue(\.fieldValue, .category)
        .navigationTitle(editorTitle)
        .toolbarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                if showsCancel {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            ToolbarItem(placement: .confirmationAction) {
                DoneButton {
                    withAnimation {
                        save(); dismiss()
                    }
                }
                .disabled(!representation.validate())
            }
        }
        .onAppear {
            if let category, category.externalIdentifier.entityIdentifierString != representation.id {
                representation = category.objectRepresentation
            }
        }
    }
    
    @MainActor
    var list: some View {
        List {
            VStack(alignment: .center, spacing: 20.0) {
                icon.frame(width: 96.0, height: 96.0)
                    .shadow(color: colorScheme == .light ? Color(colorName: representation.colorName).opacity(0.3) : .black.opacity(0.3), radius: 8.0)
                    .padding(.top, 4.0)
                
                RoundedRectangle(cornerRadius: 12.0)
                    .fill(isFocused ? Color.ui(.secondarySystemFill) : Color.ui(.tertiarySystemFill))
                    .animation(.default, value: isFocused)
                    .frame(height: 56.0)
                    .overlay(alignment: .center) {
                        TextField("Category Name", text: $representation.name)
                            .focused($isFocused)
                            #if os(iOS)
                            .introspect(.textField, on: .iOS(.v13, .v14, .v15, .v16, .v17, .v18)) { textField in
                                    textField.clearButtonMode = .whileEditing
                                    textField.textAlignment = .center
                                }
                            #endif
                            .foregroundStyle(Color(colorName: representation.colorName))
                            .font(.title2)
                            .fontWeight(.bold)
                            .padding(.horizontal, 12.0)
                    }
            }
            
            if !categoryGroups.isEmpty {
                Section {
                    group
                }
            }

            Section {
                Toggle(isOn: $representation.isIncome) {
                    Text("Treat as Income")
                }
                
                Toggle(isOn: $representation.isTransient) {
                    Text("Exclude from Summary")
                }
            }
            
            Section {
                ColorGrid(selection: $representation.colorName, columns: [GridItem(.adaptive(minimum: 38.0, maximum: 42.0), spacing: 16.0)], spacing: 16.0)
            }
            Section {
                SymbolGrid(selection: $representation.symbolName, columns: [GridItem(.adaptive(minimum: 38.0, maximum: 42.0), spacing: 16.0)], spacing: 16.0)
            }
        }
        #if os(iOS)
        .contentMargins(.top, .compact, for: .scrollContent)
        .listStyle(.insetGrouped)
        .listSectionSpacing(.compact)
        .listRowInsets(EdgeInsets(top: 16.0, leading: 16.0, bottom: 16.0, trailing: 16.0))
        #endif
    }
    
    var form: some View {
        Form {
            LabeledContent("Icon:") {
                icon.frame(width: 34.0, height: 34.0)
                    .onTapGesture {
                        showPicker.toggle()
                    }
                    .popover(isPresented: $showPicker, arrowEdge: .top) {
                        SymbolGrid(selection: $representation.symbolName, columns: [GridItem(.adaptive(minimum: 30.0, maximum: 30.0), spacing: 12.0)], spacing: 12.0)
                            .padding(12.0)
                            .frame(width: 264)
                    }
            }
            
            TextField("Name:", text: $representation.name)
            
            if !categoryGroups.isEmpty {
                LabeledContent("Group:") {
                    group.labelsHidden()
                        .padding(.top, 8.0)
                }
            }
            
            LabeledContent("Color:") {
                ColorGrid(selection: $representation.colorName, columns: [], spacing: 8.0)
                    .padding(.top, 8.0)
            }
            
            Divider()
                .padding(.bottom, 8.0)

            Toggle(isOn: $representation.isIncome) {
                Text("Treat as Income")
            }
            
            Toggle(isOn: $representation.isTransient) {
                Text("Exclude from Summary")
            }
        }
        .padding()
    }
    
    var icon: some View {
        Image(systemName: representation.symbolName.rawValue)
            .resizable()
            .symbolVariant(.circle.fill)
            .symbolRenderingMode(.palette)
            .foregroundStyle(.white, Color(colorName: representation.colorName).gradient)
    }
    
    @ViewBuilder
    var group: some View {
        Picker("Group", selection: $representation.groupID) {
            Text("None")
                .tag(Optional<UUID>.none)
            ForEach(categoryGroups) { categoryGroup in
                Text(categoryGroup.name)
                    .tag(Optional<UUID>(categoryGroup.externalIdentifier))
            }
        }
        #if os(iOS)
        .pickerStyle(.navigationLink)
        #endif
    }
    
    init(_ category: Category? = nil, showsCancel: Bool = true) {
        self.category = category
        self.showsCancel = showsCancel
    }
}

// MARK: - Operations

extension CategoryEditorView {
    @MainActor
    private func save() {
        let category = category ?? {
            let category = Category()
            modelContext.insert(category)
            return category
        }()
        
        category.objectRepresentation = representation
        
        HapticFeedback.impact(flexibility: .soft).play()
    }
}

#Preview {
    NavigationStack {
        CategoryEditorView()
    }
    .modelContainer(previewContainer)
}

struct ColorGrid: View {
    @Binding var selection: ColorName
    let columns: [GridItem]
    let spacing: CGFloat?
    
    var body: some View {
        #if os(iOS)
        LazyVGrid(columns: columns, spacing: spacing) {
            item(Color.ui(.quaternarySystemFill), isSelected: !ColorName.elevenCases.contains(selection))
                .overlay(alignment: .center) {
                    ColorSelectorItem(selection: $selection)
                }
    
            ForEach(ColorName.elevenCases, id: \.self) { colorName in
                item(Color(colorName: colorName), isSelected: selection == colorName)
                    .onTapGesture {
                        selection = colorName
                    }
            }
        }
        #else
        VStack(spacing: spacing) {
            HStack(spacing: spacing) {
                ForEach(ColorName.twelveCases.prefix(6), id: \.self) { colorName in
                    item(Color(colorName: colorName), isSelected: selection == colorName)
                        .frame(width: 16.0, height: 16.0)
                        .onTapGesture {
                            selection = colorName
                        }
                }
            }
            
            HStack(spacing: spacing) {
                ForEach(ColorName.twelveCases.suffix(6), id: \.self) { colorName in
                    item(Color(colorName: colorName), isSelected: selection == colorName)
                        .frame(width: 16.0, height: 16.0)
                        .onTapGesture {
                            selection = colorName
                        }
                }
            }
        }
        #endif
    }
    
    func item(_ color: Color, isSelected: Bool) -> some View {
        #if os(iOS)
        Circle()
            .fill(color)
            .background {
                Circle()
                    .stroke(isSelected ? Color.ui(.placeholderText) : Color.clear, lineWidth: 3.0)
                    .padding(-5.0)
            }
        #else
        Circle()
            .fill(color)
            .overlay {
                if isSelected {
                    Circle()
                        .fill(.white)
                        .frame(width: 6.0, height: 6.0)
                }
            }
        #endif
    }
}

struct SymbolGrid: View {
    @Binding var selection: SymbolName
    let columns: [GridItem]
    let spacing: CGFloat?
    
    var body: some View {
        LazyVGrid(columns: columns, spacing: spacing) {
            ForEach(SymbolName.Category.allCases, id: \.self) { categoryIcon in
                item(categoryIcon.rawValue, isSelected: selection == categoryIcon.rawValue)
                    .onTapGesture {
                        selection = categoryIcon.rawValue
                    }
            }
        }
    }
    
    func item(_ symbolName: SymbolName, isSelected: Bool) -> some View {
        Image(systemName: symbolName.rawValue)
            .resizable()
            .aspectRatio(1.0, contentMode: .fit)
            .symbolVariant(.circle.fill)
            .symbolRenderingMode(.palette)
            .foregroundStyle(.primary.opacity(0.8), Color.ui(.quaternarySystemFill))
            .background {
                Circle()
                    .stroke(isSelected ? Color.ui(.placeholderText) : Color.clear, lineWidth: 3.0)
                    .padding(-5.0)
            }
    }
}

private extension ColorName {
    static let elevenCases: [ColorName] = [red, orange, yellow, green, teal, cyan, blue, indigo, purple, pink, brown]
    static let twelveCases = [red, orange, yellow, green, teal, cyan, blue, indigo, purple, pink, brown, gray]
}
