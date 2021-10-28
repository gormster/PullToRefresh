//
//  PullToRefresh.swift
//  PullToRefresh
//
//  Created by Morgan Harris on 28/10/21.
//

import SwiftUI

struct TopAnchorPreference: PreferenceKey {
    static var defaultValue: Anchor<CGPoint>? = nil
    
    static func reduce(value: inout Anchor<CGPoint>?, nextValue: () -> Anchor<CGPoint>?) {
        value = value ?? nextValue()
    }
}

public enum PullToRefreshState: String {
    case waiting, primed, refreshing, complete
}

struct PullToRefreshStatePreference: PreferenceKey {
    static func reduce(value: inout PullToRefreshState, nextValue: () -> PullToRefreshState) {
        value = nextValue()
    }
    
    static var defaultValue: PullToRefreshState = .waiting
}

struct PullToRefreshStateEnvironmentKey: EnvironmentKey {
    static let defaultValue: PullToRefreshState = .waiting
}

public extension EnvironmentValues {
    var pullToRefreshState: PullToRefreshState {
        get { self[PullToRefreshStateEnvironmentKey.self] }
        set { self[PullToRefreshStateEnvironmentKey.self] = newValue }
    }
}
