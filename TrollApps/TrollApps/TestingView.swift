//
//  TestingView.swift
//  TrollApps
//
//  Created by Cleo Debeau on 2023-12-13.
//

import SwiftUI
import SDWebImageSwiftUI

struct TestingView: View {
    @State private var isCardShown = false
    @Namespace private var namespace
    
    var body: some View {
        GeometryReader { geo in
            if isCardShown {
                WebImage(url: URL(string: "https://www.thebluediamondgallery.com/handwriting/images/testing.jpg"))
                    .resizable()
                    .scaledToFill()
                    .matchedGeometryEffect(id: "card", in: namespace)
                    .frame(maxWidth: geo.size.width, maxHeight: geo.size.height, alignment: .center)
                    .onTapGesture {
                        withAnimation(.spring()) {
                            isCardShown.toggle()
                        }
                    }
            } else {
                WebImage(url: URL(string: "https://www.thebluediamondgallery.com/handwriting/images/testing.jpg"))
                    .resizable()
                    .scaledToFill()
                    .matchedGeometryEffect(id: "card", in: namespace)
                    .frame(maxWidth: geo.size.width, maxHeight: geo.size.height, alignment: .center)
                    .onTapGesture {
                        withAnimation(.spring()) {
                            isCardShown.toggle()
                        }
                    }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
    }
}


