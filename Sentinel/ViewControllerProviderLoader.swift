import UIKit

/**
 Implementations of ViewControllerProviderLoader should return an array of each of the app's
 ViewControllerProviderFactory implementations so that they can create a ViewControllerProvider and registered it with
 the registry.

 At the moment, the only implementation is the RuntimeViewControllerProviderLoader which uses Runtime magic to find
 all loaded classes that implement ViewControllerProviderFactory. This is used to create a ViewControllerProvider.

 This might not be a long term solution, especially if Swift moves away from the Obj-C runtime, but it does serve as a
 nice example of accessing the Obj-C runtime from Swift.

 Other implementations can be written that (e.g.) manually instantiate the required implementations, or maybe load them
 via a plist.
 */
protocol ViewControllerProviderLoader {
    func viewControllerProviderFactories() -> [ViewControllerProviderFactory.Type]
}
