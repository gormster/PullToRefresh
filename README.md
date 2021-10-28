# PullToRefresh

This package adds far more flexible pull-to-refresh functionality to SwiftUI, for iOS 14 and 15.

<p align="center">
    <img alt="RefreshableScrollView" src="https://user-images.githubusercontent.com/152158/139188144-c17025f7-64db-4b03-bb79-16fda9b2f846.gif" />
</p>

* Usable in any view through a pair of view modifiers
* Convenient `RefreshableScrollView` container
* Allows full customisation of the refreshing view

## Using `RefreshableScrollView`

Replace your `ScrollView` with `RefreshableScrollView` and add the `refreshCallback:` parameter.

```swift
class ViewModel {
    func startRefresh(completion: @escaping () -> Void) {
        // Do something...
        
        completion()
    }
}
```

```swift
RefreshableScrollView(refreshCallback: viewModel.startRefresh(completion:)) {
    YourScrollContentView()
}
```
        
## Customising the refresh view

You can use any view for the refresh view; just throw in an environment variable to watch the pull to refresh state and you're done.

```swift 
struct MyCustomRefreshView: View {
    @Environment(\.pullToRefreshState) var refreshState
    
    // Your custom view body goes here!
}
```

Then, pass it in as a parameter to `RefreshableScrollView` or `pullToRefreshContainer()`.

```swift
RefreshableScrollView(refreshCallback: viewModel.startRefresh(completion:), refreshView: MyCustomRefreshView()) {
    YourScrollContentView()
}
```

## Customising `PullToRefreshView`

You can easily change the indicator views for the default PullToRefreshView, too.

```swift
let refreshView = PullToRefreshView(indicatorView: Image(systemName: "arrow.clockwise.circle.fill"))
```


## Using the modifiers

If you want to apply pull-to-refresh to a different type of view, you can use the view modifiers `pullToRefreshContent()` and `pullToRefreshContainer`. The former goes on the content (as in the thing that the user drags with their finger) and the latter goes on the container (as in the thing that stays still when the user drags the content). If your container takes multiple views, apply the content modifier to the one at the top. 

```swift
List(items) { item
    Color.clear.pullToRefreshContent()
    
    YourListItemView(item)
}
.pullToRefreshContainer { viewModel.startRefresh(completion: $0) }
```
