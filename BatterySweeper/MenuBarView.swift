//
//  ContentView.swift
//  BatterySweeper
//
//  Created by Dmitry Poyarkov on 2/7/25.
//

import SwiftUI

struct MenuBarView: View {
    let id: UUID = .init()
    
    @Environment(PeripheralViewModel.self) private var viewModel
    
    @State private var isPeripheralHovered: [UUID: Bool] = [:]
    @State private var isQuitButtonHovered: Bool = false

    var body: some View {
        VStack(alignment: .leading) {
            ForEach(viewModel.peripherals) { peripheral in
                Button {
                    withAnimation {
                        viewModel.selectPeripheral(peripheral)
                    }
                } label: {
                    HStack {
                        Text(peripheral.name)
                            .foregroundStyle(
                                Color(nsColor: viewModel.activePeripheral == peripheral ? .labelColor : .secondaryLabelColor)
                            )
                            .lineLimit(1)
                            .truncationMode(.tail)
                        Spacer()
                        Text("\(peripheral.battery)%")
                    }
                    .padding(.horizontal, 9)
                    .padding(.vertical, 3)
                    .contentShape(Rectangle())
                }
                .background(in: RoundedRectangle(cornerRadius: 5))
                .backgroundStyle(
                    Color(nsColor: isPeripheralHovered[peripheral.id] ?? false ? .selectedContentBackgroundColor: .clear)
                )
                .onHover { value in
                    isPeripheralHovered.updateValue(value, forKey: peripheral.id)
                }
            }
            
            // TODO: refresh list

            Divider()
            
            Button {
                exit(0)
            } label: {
                Text("Quit Battery Sweeper")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 9)
                    .padding(.vertical, 3)
                    .contentShape(Rectangle())
            }
            .background(in: RoundedRectangle(cornerRadius: 5))
            .backgroundStyle(isQuitButtonHovered
                             ? Color(nsColor: .selectedContentBackgroundColor)
                             : Color.clear
            )
            .onHover { value in
                isQuitButtonHovered = value
            }
        }
        .frame(maxWidth: 200)
        .font(.system(size: 14))
        .buttonStyle(.plain)
        .padding(5)
        .focusable(false)
        .onAppear {
            isPeripheralHovered = Dictionary(uniqueKeysWithValues: viewModel.peripherals.map { ($0.id, false)} )
        }
    }
}

#Preview {
    MenuBarView()
}
