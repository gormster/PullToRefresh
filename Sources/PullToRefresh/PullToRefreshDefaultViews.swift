//
//  SwiftUIView.swift
//  SwiftUIView
//
//  Created by Morgan Harris on 21/9/21.
//

import SwiftUI

// MARK: - Default views (iOS 14)

// This is done to force Swift to resolve these `some View` types into concrete types
@available(iOS 14.0, *)
public protocol PullToRefreshDefaultViews {
    associatedtype DefaultIndicatorView: View
    associatedtype DefaultRefreshingView: View
    
    static var defaultIndicatorView: DefaultIndicatorView { get }
    static var defaultRefreshingView: DefaultRefreshingView { get }
}

@available(iOS 14.0, *)
public struct PullToRefreshDefaults: PullToRefreshDefaultViews {
    public static var defaultIndicatorView: some View {
        Image(systemName: "arrow.clockwise")
    }
    
    public static var defaultRefreshingView: some View {
        ProgressView().progressViewStyle(.circular)
    }
}
