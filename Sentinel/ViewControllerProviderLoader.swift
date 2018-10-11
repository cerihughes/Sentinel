import UIKit

/**
 Implementations of ViewControllerProviderLoader should create an instance of each of the app's ViewControllerProvider
 implementations so that they can be registered by the UI class.

 At the moment, the only implementation is the RuntimeViewControllerProviderLoader which uses Runtime magic to find
 all loaded classes that implement ViewControllerProviderFactory. This is used to create a ViewControllerProvider.

 This might not be a long term solution, especially if Swift moves away from the Obj-C runtime. It also means that
 implementations also need to extend from NSObject, so it's not the Swiftiest way of doing things - it does serve as a
 nice example of accessing the Obj-C runtime from Swift though.

 Other implementations can be written that (e.g.) manually instantiate the required implementations, or maybe load them
 via a plist.
 */
protocol ViewControllerProviderLoader {
    func createViewControllerProviders() -> [ViewControllerProvider]
}
