//
//  PullToRefreshView.swift
//  PullToRefreshView
//
//  Created by Morgan Harris on 28/10/21.
//

import Foundation
import SwiftUI

/// A useful view for displaying a common pull-to-refresh indicator. Can be customised with varying indicator and refreshing views.
public struct PullToRefreshView<IndicatorView: View, RefreshingView: View>: View {
    var indicatorView: IndicatorView
    var refreshingView: RefreshingView
    
    @Environment(\.pullToRefreshState) private var refreshState
    
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

