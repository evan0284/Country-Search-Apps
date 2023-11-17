//
//  SearchBar.swift
//  country-assignment-2-3
//
//  Created by Evans on 2023-11-14.
//

import Foundation
import SwiftUI


struct SearchBar: View {
    @Binding var text: String
    
    var body: some View {
        HStack {
            TextField("Search", text: $text)
                .padding(8)
                .background(Color(.systemGray6))
                .cornerRadius(8)
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
            if !text.isEmpty {
                Button(action: {
                    self.text = ""
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .imageScale(.medium)
                        .foregroundColor(Color(.systemGray3))
                        .padding(5)
                }
                .padding(.trailing, 10)
            }
        }
    }
}
