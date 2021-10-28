//
//  RefreshableScrollView.swift
//  RefreshableScrollView
//
//  Created by Morgan Harris on 28/10/21.
//

import Foundation
import SwiftUI

// MARK: - RefreshableScrollView

public struct RefreshableScrollView<Content: View, RefreshView: View>: View {
    var refreshCallback: PullToRefreshCallback
    var refreshView: RefreshView
    var startRefreshingOffset: CGFloat
    var completionDelay: TimeInterval
    var content: Content
    
    @State private var refreshState: PullToRefreshState = .waiting
    
    public init(refreshCallback: @escaping PullToRefreshCallback,
                refreshView: RefreshView,
                startRefreshingOffset: CGFloat = 64,
                completionDelay: TimeInterval = 1.0,
                @ViewBuilder content: () -> Content) {
        self.refreshCallback = refreshCallback
        self.refreshView = refreshView
        self.startRefreshingOffset = startRefreshingOffset
        self.completionDelay = completionDelay
        self.content = content()
    }
    
    public var body: some View {
        ScrollView {
            content.pullToRefreshContent()
        }
        .pullToRefreshContainer(refreshState: $refreshState,
                                refreshView: refreshView,
                                startRefreshingOffset: startRefreshingOffset,
                                completionDelay: completionDelay,
                                refreshCallback: refreshCallback)
    }
}

extension RefreshableScrollView {
    public init(refreshCallback: @escaping PullToRefreshCallback,
                startRefreshingOffset: CGFloat = 64,
                @ViewBuilder content: () -> Content)
    where RefreshView == PullToRefreshView<PullToRefreshDefaults.DefaultIndicatorView,
                                          PullToRefreshDefaults.DefaultRefreshingView> {
        self.init(
                refreshCallback: refreshCallback,
                refreshView: PullToRefreshView(),
                startRefreshingOffset: startRefreshingOffset,
                content: content
        )
    }
}

// MARK: - Previews

#if DEBUG

extension Double {
    static let phi: Double = (1 + sqrt(5)) / 2
    
    var fractionalPart: Double {
        self.truncatingRemainder(dividingBy: 1.0)
    }
}

internal struct TestView: View {
    class ViewModel: ObservableObject {
        var workItem: DispatchWorkItem?
        func startRefresh(completion: @escaping () -> Void) {
            guard workItem == nil else {
                debugText = "already refreshing"
                return
            }
            
            workItem = DispatchWorkItem { [weak self] in
                self?.debugText = "finished refresh"
                self?.workItem = nil
                completion()
            }
            
            debugText = "refreshing now"
            DispatchQueue.main.asyncAfter(deadline: .now() + .random(in: 2 ... 3), execute: workItem!)
        }
        
        var debugText = ""
    }
    
    @StateObject var viewModel = ViewModel()
    
    var body: some View {
        RefreshableScrollView(refreshCallback: viewModel.startRefresh(completion:)) {
            VStack {
                ForEach(0 ..< 40) { i in
                    let hue = ((Double(i) / 10.0) * .phi )
                    let color = Color(hue: hue.fractionalPart, saturation: 0.8, brightness: 1.0, opacity: 0.3)
                    Text("Item #\(i)")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 5).fill(color))
                        .padding()
                }
            }
        }
        .clipped()
        .overlay(Text(viewModel.debugText))
    }
}

internal struct TestView_Previews: PreviewProvider {
    static var previews: some View {
        TestView()
    }
}

#endif
