//
//  PullToRefresh.swift
//  PullToRefresh
//
//  Created by Morgan Harris on 28/10/21.
//

import SwiftUI

@available(iOS 13.0, *)
struct TopAnchorPreference: PreferenceKey {
    static var defaultValue: Anchor<CGPoint>? = nil
    
    static func reduce(value: inout Anchor<CGPoint>?, nextValue: () -> Anchor<CGPoint>?) {
        value = value ?? nextValue()
    }
}

public enum PullToRefreshState: String {
    case waiting, primed, refreshing, complete
}

@available(iOS 13.0, *)
struct PullToRefreshStatePreference: PreferenceKey {
    static func reduce(value: inout PullToRefreshState, nextValue: () -> PullToRefreshState) {
        value = nextValue()
    }
    
    static var defaultValue: PullToRefreshState = .waiting
}


// MARK: - PTR View

@available(iOS 13, *)
public struct PullToRefreshView<IndicatorView: View, RefreshingView: View>: View {
    var refreshState: PullToRefreshState
    var indicatorView: IndicatorView
    var refreshingView: RefreshingView
    
    public var body: some View {
        ZStack {
            refreshingView
                .scaleEffect(refreshState == .refreshing ? 1.0 : 0.0, anchor: .center)
            
            indicatorView
                .rotationEffect((refreshState == .waiting || refreshState == .complete) ? .zero : .degrees(360))
                .scaleEffect((refreshState == .refreshing || refreshState == .complete) ? 0.0 : 1.0, anchor: .center)
        }
        .animation(.easeInOut(duration: 0.3), value: refreshState)
    }
}


