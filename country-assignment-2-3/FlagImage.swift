//
//  Model.swift
//  country-assignment-2-3
//
//  Created by Evans on 2023-11-14.
//

import SwiftUI
import SVGKit

struct SVGImageView: View {
    let svgURL: URL
    @State private var imageSize: CGSize? = nil

    var body: some View {
        Group {
            if imageSize != nil {
                Image(uiImage: SVGKImage(contentsOf: svgURL)?.uiImage ?? UIImage(systemName: "xmark.circle")!)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 40, height: 30)
            } else {
                ProgressView()
            }
        }
        .onAppear {
            DispatchQueue.global().async {
                let svgImage = SVGKImage(contentsOf: svgURL)
                let size = svgImage?.size
                DispatchQueue.main.async {
                    self.imageSize = size
                }
            }
        }
    }
}

struct SVGBigImageView: View {
    let svgURL: URL
    @State private var imageSize: CGSize? = nil

    var body: some View {
        Group {
            if imageSize != nil {
                Image(uiImage: SVGKImage(contentsOf: svgURL)?.uiImage ?? UIImage(systemName: "xmark.circle")!)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 300, height: 200)
            } else {
                ProgressView()
            }
        }
        .onAppear {
            DispatchQueue.global().async {
                let svgImage = SVGKImage(contentsOf: svgURL)
                let size = svgImage?.size
                DispatchQueue.main.async {
                    self.imageSize = size
                }
            }
        }
    }
}
