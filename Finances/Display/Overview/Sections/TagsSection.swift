//
//  TagsSection.swift
//  Finances
//
//  Created by Dmitriy Zharov on 05.12.2023.
//

import SwiftUI
import SwiftData

#if os(iOS)
private extension UIColor {
    static var tagLabel: UIColor {
        UIColor { traitCollection in
            if traitCollection.userInterfaceStyle == .light {
                return UIColor(red: 131 / 255, green: 131 / 255, blue: 136 / 255, alpha: 1.0)
            } else {
                return UIColor(red: 160 / 255, green: 160 / 255, blue: 168 / 255, alpha: 1.0)
            }
        }
    }
    
    static var tagBackgroundColor: UIColor {
        UIColor { traitCollection in
            if traitCollection.userInterfaceStyle == .light {
                return UIColor(red: 238 / 255, green: 238 / 255, blue: 239 / 255, alpha: 1.0)
            } else {
                return UIColor(red: 49 / 255, green: 49 / 255, blue: 53 / 255, alpha: 1.0)
            }
        }
    }
}
#endif

#if os(macOS)
extension NSColor {
    static var tagLabel: NSColor {
        NSColor.label
    }
    
    static var tagBackgroundColor: NSColor {
        NSColor.secondarySystemFill
    }
}
#endif

struct ChipsItem: View {
    let isSelected: Bool?
    let text: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(text)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(foregroundColor)
                .padding(.horizontal, 12.0)
                .padding(.vertical, 8.0)
                .background() {
                    RoundedRectangle(cornerRadius: 8.0, style: .continuous)
                        .fill(backgroundColor)
                }
        }
        .buttonStyle(.plain)
    }
    
    var foregroundColor: Color {
        if let isSelected, isSelected == true {
            return Color.white
        } else {
            return Color.ui(.tagLabel)
        }
    }
    
    var backgroundColor: Color {
        if let isSelected, isSelected == true {
            return Color.accent
        } else {
            return Color.ui(.tagBackgroundColor)
        }
    }
    
    init(isSelected: Bool? = false, _ text: String, action: @escaping () -> Void) {
        self.isSelected = isSelected
        self.text = text
        self.action = action
    }
}

struct TagsSection: View {
    @Environment(\.navigator) private var navigator
    @Environment(\.editMode) private var editMode
    
    @Query(sort: \Tag.name, order: .forward) private var tags: [Tag]
    
    var header: some View {
        Text("Tags")
            .listHeaderStyle(.large)
            .listRowInsets(.init(top: 10, leading: 0, bottom: 8.0, trailing: 0))
            .headerProminence(.increased)
    }
    
    var body: some View {
#if DEBUG
        let _ = Self._printChanges()
#endif
        if !tags.isEmpty {
            Section {
                OverflowStack(spacing: 8.0) {
                    ForEach(tags, id: \.route) { tag in
                        item(for: tag)
                    }
                }
                #if os(iOS)
                .padding(16.0)
                .listRowInsets(.zero)
                .listRowBackground(Color.ui(.secondarySystemGroupedBackground))
                #endif
            } header: {
                header
            }
            #if os(iOS)
            .listSectionSpacing(.default)
            #endif
            .disabled(editMode.isEditing)
        }
    }
    
    @MainActor
    func item(for tag: Tag) -> some View {
        ChipsItem(isSelected: navigator.root == tag.route, "#" + tag.name) {
            Task { @MainActor in
                navigator.root = tag.route
            }
        }
    }
}

private extension Tag {
    var route: NavigationRoute {
        .tags(ids: Set<Tag.ExternalID>([externalIdentifier]))
    }
}
