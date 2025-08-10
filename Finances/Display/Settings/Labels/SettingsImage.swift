//
//  SettingsImage.swift
//  Finances
//
//  Created by Dmitriy Zharov on 17.12.2023.
//

import SwiftUI
import AppUI

struct SettingImage: View {
    @Environment(\.backgroundStyle) private var backgroundStyle
    
    private let setting: SymbolName.Setting
    private let size: CGFloat = {
        #if os(iOS)
        return 30.0
        #else
        return 20.0
        #endif
    }()
    
    var body: some View {
        switch setting {
        case .gearshape:
            icon.foregroundStyle(.white, .gray)
        case .star:
            icon.foregroundStyle(.white, .teal)
        case .currency:
            icon.foregroundStyle(.white, .accent)
        case .paperclip:
            customIcon.foregroundStyle(.orange)
        case .storefront:
            Image(systemName: setting.rawValue.rawValue)
                .resizable()
                .symbolVariant(.circle.fill)
                .symbolRenderingMode(.palette)
                .foregroundStyle(.white, .red)
                .frame(width: size, height: size)
                .background {
                    RoundedRectangle(cornerRadius: 4.0, style: .continuous)
                        .foregroundStyle(.red)
                        .frame(width: size, height: size)
                }
        case .number:
            icon.foregroundStyle(.white, .gray)
        case .bell:
            icon.foregroundStyle(.white, .red)
        case .lock:
            icon.foregroundStyle(.white, .green)
        case .lightbulb:
            Image(systemName: setting.rawValue.rawValue)
                .resizable()
                .symbolVariant(.circle.fill)
                .symbolRenderingMode(.palette)
                .foregroundStyle(.white, .purple)
                .frame(width: size, height: size)
                .background {
                    RoundedRectangle(cornerRadius: 4.0, style: .continuous)
                        .foregroundStyle(.purple)
                        .frame(width: size, height: size)
                }
        case .icloud:
            icon.foregroundStyle(.white, .blue)
        case .transfer:
            icon.foregroundStyle(.white, .mint)
        case .externaldrive:
            customIcon.foregroundStyle(.brown)
        case .heart:
            icon.foregroundStyle(.white, .pink)
        case .envelope:
            customIcon.foregroundStyle(.teal)
        case .curlybraces:
            icon.foregroundStyle(.white, .cyan)
        case .house:
            Image(systemName: setting.rawValue.rawValue)
                .resizable()
                .symbolVariant(.circle.fill)
                .symbolRenderingMode(.palette)
                .foregroundStyle(.white, .clear)
                .frame(width: size, height: size)
                .background {
                    RoundedRectangle(cornerRadius: 4.0, style: .continuous)
                        .foregroundStyle(.orange)
                        .frame(width: size, height: size)
                }
        case .date:
            RoundedRectangle(cornerRadius: 4.0, style: .continuous)
                .frame(width: size, height: size)
                .foregroundStyle(.blue)
                .overlay {
                    Image(systemName: setting.rawValue.rawValue)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .symbolVariant(.fill)
                        .symbolRenderingMode(.palette)
                        .frame(width: size * 0.6, height: size * 0.6)
                        .foregroundStyle(.white)
                }
        case .repeat:
            Image(systemName: setting.rawValue.rawValue)
                .resizable()
                .symbolVariant(.circle.fill)
                .symbolRenderingMode(.palette)
                .foregroundStyle(.white, .clear)
                .frame(width: size, height: size)
                .background {
                    RoundedRectangle(cornerRadius: 4.0, style: .continuous)
                        .foregroundStyle(.indigo)
                        .frame(width: size, height: size)
                }
        case .asset:
            RoundedRectangle(cornerRadius: 4.0, style: .continuous)
                .frame(width: size, height: size)
                .foregroundStyle(.accent)
                .overlay {
                    Image(systemName: setting.rawValue.rawValue)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .symbolVariant(.fill)
                        .symbolRenderingMode(.palette)
                        .frame(width: size * 0.6, height: size * 0.6)
                        .foregroundStyle(.white)
                }
        case .pencil:
            Image(systemName: setting.rawValue.rawValue)
                .resizable()
                .symbolVariant(.circle.fill)
                .symbolRenderingMode(.palette)
                .foregroundStyle(.white, .clear)
                .frame(width: size, height: size)
                .background {
                    RoundedRectangle(cornerRadius: 4.0, style: .continuous)
                        .foregroundStyle(backgroundStyle ?? AnyShapeStyle(.fill))
                        .frame(width: size, height: size)
                }
        }
    }
    
    
    private var icon: some View {
        Image(systemName: setting.rawValue.rawValue)
            .resizable()
            .symbolVariant(.square.fill)
            .symbolRenderingMode(.palette)
            .frame(width: size, height: size)
    }
    
    private var customIcon: some View {
        RoundedRectangle(cornerRadius: 4.0, style: .continuous)
            .frame(width: size, height: size)
            .overlay {
                Image(systemName: setting.rawValue.rawValue)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .symbolVariant(.fill)
                    .symbolRenderingMode(.palette)
                    .frame(width: size / 3.0 * 2.0, height: size / 3.0 * 2.0)
                    .foregroundStyle(.white)
            }
    }
    
    init(_ setting: SymbolName.Setting) {
        self.setting = setting
    }
}
