import Foundation

/**
 An implementation of ViewControllerProviderLoader which uses objc-runtime magic to find all loaded classes that
 implement ViewControllerProvider. It requires all ViewControllerProvider to also inherit from NSObject, so it's not
 the Swiftiest way of doing things - it does serve as a nice example of accessing the Obj-C runtime from Swift though.
 */
class RuntimeViewControllerProviderLoader: ViewControllerProviderLoader {

    // MARK: ViewControllerProviderLoader

    func createViewControllerProviders() -> [ViewControllerProvider] {
        var viewControllerProviders: [ViewControllerProvider] = []

        if let executablePath = Bundle.main.executablePath {
            var classCount: UInt32 = 0
            let classNames = objc_copyClassNamesForImage(executablePath, &classCount)
            if let classNames = classNames {
                for i in 0 ..< classCount {
                    let className = classNames[Int(i)]
                    let name = String.init(cString: className)

                    if let cls = NSClassFromString(name) as? ViewControllerProviderFactory.Type {
                        let instance = cls.createViewControllerProvider()
                        viewControllerProviders.append(instance)
                    }
                }
            }

            free(classNames);
        }

        return viewControllerProviders
    }

}
