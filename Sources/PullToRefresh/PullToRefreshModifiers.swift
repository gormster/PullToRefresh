//
//  PullToRefreshModifiers.swift
//  
//
//  Created by Morgan Harris on 28/10/21.
//

import Foundation
import SwiftUI

// MARK: - Content modifier

private let reloadIndicatorId = "reloadIndicator"
private let scrollTopId = "scrollTop"

struct PullToRefreshContentModifier: ViewModifier {
    @Environment(\.pullToRefreshNamespace) private var reloadNamespace
    @Environment(\.pullToRefreshState) private var refreshState
    
    func body(content: Content) -> some View {
        if let reloadNamespace = reloadNamespace {
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
}

public extension View {
    func pullToRefreshContent() -> some View {
        modifier(PullToRefreshContentModifier())
    }
}

// MARK: - Container modifier

struct PullToRefreshContainerModifier<RefreshView: View>: ViewModifier {
    var refreshCallback: PullToRefreshCallback
    var refreshView: RefreshView
    var startRefreshingOffset: CGFloat
    var completionDelay: TimeInterval
    
    @Binding var refreshState: PullToRefreshState
    
    @Namespace private var reloadNamespace
    
    public init(refreshCallback: @escaping PullToRefreshCallback,
                refreshState: Binding<PullToRefreshState>,
                refreshView: RefreshView,
                startRefreshingOffset: CGFloat = 64,
                completionDelay: TimeInterval = 1.0) {
        self.refreshCallback = refreshCallback
        self.refreshView = refreshView
        self.startRefreshingOffset = startRefreshingOffset
        self.completionDelay = completionDelay
        self._refreshState = refreshState
    }
    
    func body(content: Content) -> some View {
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
        
            content
                .environment(\.pullToRefreshState, refreshState)
                .environment(\.pullToRefreshNamespace, reloadNamespace)
        }
        .overlayPreferenceValue(TopAnchorPreference.self) { topAnchor in
            if let topAnchor = topAnchor {
                anchorOverlay(topAnchor: topAnchor)
            }
        }
        .onPreferenceChange(PullToRefreshStatePreference.self, perform: stateChanged)
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
                
                // SwiftUI animation delays don't work when you're setting the same property,
                // so we have to use Dispatch.
                DispatchQueue.main.asyncAfter(deadline: .now() + completionDelay) {
                    refreshState = .waiting
                }
            }
        default:
            break
        }
    }
}

public extension View {
    func pullToRefreshContainer<RefreshView: View> (
        refreshState: Binding<PullToRefreshState>,
        refreshView: RefreshView,
        startRefreshingOffset: CGFloat = 64,
        completionDelay: TimeInterval = 1.0,
        refreshCallback: @escaping (@escaping () -> Void) -> Void
    ) -> some View {
        modifier(
            PullToRefreshContainerModifier(
                refreshCallback: refreshCallback,
                refreshState: refreshState,
                refreshView: refreshView,
                startRefreshingOffset: startRefreshingOffset,
                completionDelay: completionDelay
            )
        )
    }
}
