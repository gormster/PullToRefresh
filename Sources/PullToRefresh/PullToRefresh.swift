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

@available(iOS 13.0, *)
struct PullToRefreshStateEnvironmentKey: EnvironmentKey {
    static let defaultValue: PullToRefreshState = .waiting
}

@available(iOS 13.0, *)
public extension EnvironmentValues {
    var pullToRefreshState: PullToRefreshState {
        get { self[PullToRefreshStateEnvironmentKey.self] }
        set { self[PullToRefreshStateEnvironmentKey.self] = newValue }
    }
}
