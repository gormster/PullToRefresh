//
//  SwiftUIView.swift
//  SwiftUIView
//
//  Created by Morgan Harris on 21/9/21.
//

import SwiftUI

// MARK: - Default views (iOS 14)

// This is done to force Swift to resolve these `some View` types into concrete types
public protocol PullToRefreshDefaultViews {
    associatedtype DefaultIndicatorView: View
    associatedtype DefaultRefreshingView: View
    
    static var defaultIndicatorView: DefaultIndicatorView { get }
    static var defaultRefreshingView: DefaultRefreshingView { get }
}

public struct PullToRefreshDefaults: PullToRefreshDefaultViews {
    public static var defaultIndicatorView: some View {
        Image(systemName: "arrow.clockwise")
    }
    
    public static var defaultRefreshingView: some View {
        ProgressView().progressViewStyle(.circular)
    }
}

// MARK: - Default initialiser for PTR view

public extension PullToRefreshView
where IndicatorView == PullToRefreshDefaults.DefaultIndicatorView,
      RefreshingView == PullToRefreshDefaults.DefaultRefreshingView {
    init() {
        self.init(indicatorView: PullToRefreshDefaults.defaultIndicatorView,
                  refreshingView: PullToRefreshDefaults.defaultRefreshingView)
    }
}

public extension PullToRefreshView
where IndicatorView == PullToRefreshDefaults.DefaultIndicatorView {
    init(refreshingView: RefreshingView) {
        self.init(indicatorView: PullToRefreshDefaults.defaultIndicatorView,
                  refreshingView: refreshingView)
    }
}

public extension PullToRefreshView
where RefreshingView == PullToRefreshDefaults.DefaultRefreshingView {
    init(indicatorView: IndicatorView) {
        self.init(indicatorView: indicatorView,
                  refreshingView: PullToRefreshDefaults.defaultRefreshingView)
    }
}
