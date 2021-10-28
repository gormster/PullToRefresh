//
//  RefreshableScrollView.swift
//  RefreshableScrollView
//
//  Created by Morgan Harris on 28/10/21.
//

import Foundation
import SwiftUI

// MARK: - RefreshableScrollView

private let reloadIndicatorId = "reloadIndicator"
private let scrollTopId = "scrollTop"

@available(iOS 14, *)
public struct RefreshableScrollView<Content: View, RefreshView: View>: View {
    
    public typealias OnRefresh = (@escaping () -> Void) -> Void
    
    var refreshCallback: OnRefresh
    var refreshView: RefreshView
    var startRefreshingOffset: CGFloat = 64
    var content: Content
    
    @State private var refreshState: PullToRefreshState = .waiting
    
    @Namespace private var reloadNamespace
    
    public init(refreshCallback: @escaping OnRefresh,
                refreshView: RefreshView,
                startRefreshingOffset: CGFloat = 64,
                @ViewBuilder content: () -> Content) {
        self.refreshCallback = refreshCallback
        self.refreshView = refreshView
        self.startRefreshingOffset = startRefreshingOffset
        self.content = content()
    }
    
    public var body: some View {
        ZStack(alignment: .top) {
            refreshView
                .environment(\.pullToRefreshState, refreshState)
                .frame(height: startRefreshingOffset)
                .matchedGeometryEffect(id: reloadIndicatorId,
                                       in: reloadNamespace,
                                       properties: .position,
                                       anchor: .bottom,
                                       isSource: refreshState == .refreshing)
                .matchedGeometryEffect(id: scrollTopId,
                                       in: reloadNamespace,
                                       properties: .position,
                                       anchor: .bottom,
                                       isSource: false)
        
            ScrollView {
                content
                    .anchorPreference(key: TopAnchorPreference.self, value: .top) { $0 }
                    .matchedGeometryEffect(id: reloadIndicatorId,
                                           in: reloadNamespace,
                                           properties: .position,
                                           anchor: .top,
                                           isSource: false)
                    .matchedGeometryEffect(id: scrollTopId,
                                           in: reloadNamespace,
                                           properties: .position,
                                           anchor: .top,
                                           isSource: (refreshState == .waiting || refreshState == .complete))
            }
        }
        .overlayPreferenceValue(TopAnchorPreference.self) { topAnchor in
            if let topAnchor = topAnchor {
                anchorOverlay(topAnchor: topAnchor)
            }
        }
        .onPreferenceChange(PullToRefreshStatePreference.self, perform: stateChanged)
        .clipped()
    }
    
    private func anchorOverlay(topAnchor: Anchor<CGPoint>) -> some View {
        GeometryReader { geometryProxy in
            if geometryProxy[topAnchor].y > startRefreshingOffset {
                Color.clear.preference(key: PullToRefreshStatePreference.self, value: .primed)
            } else {
                Color.clear.preference(key: PullToRefreshStatePreference.self, value: .refreshing)
            }
        }
    }
    
    private func stateChanged(newValue: PullToRefreshState) {
        switch (refreshState, newValue) {
        case (.waiting, .primed):
            refreshState = .primed
        case (.primed, .refreshing):
            refreshState = .refreshing
            refreshCallback {
                withAnimation(.default) {
                    refreshState = .complete
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    refreshState = .waiting
                }
            }
        default:
            break
        }
    }
}

@available(iOS 14, *)
extension RefreshableScrollView {
    public init(refreshCallback: @escaping OnRefresh,
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

@available(iOS 14, *)
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
        RefreshableScrollView(refreshCallback: viewModel.startRefresh) {
            VStack {
                ForEach(0 ..< 40) { i in
                    let hue = ((Double(i) / 10.0) * .phi )
                    Text("Item #\(i)")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 5)
                                        .fill(Color(hue: hue.fractionalPart, saturation: 0.8, brightness: 1.0, opacity: 0.3)))
                        .padding()
                }
            }
        }.clipped()
            .overlay(Text(viewModel.debugText))
    }
}

@available(iOS 14, *)
internal struct TestView_Previews: PreviewProvider {
    static var previews: some View {
        TestView()
    }
}

#endif
