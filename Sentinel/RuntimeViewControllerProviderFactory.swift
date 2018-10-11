import Foundation

/**
 An implementation of ViewControllerProviderFactory which uses objc-runtime magic to find all loaded classes that
 implement ViewControllerProvider. It requires all ViewControllerProvider to also inherit from NSObject, so it's not
 the Swiftiest way of doing things - it does serve as a nice example of accessing the Obj-C runtime from Swift though.
 */
class RuntimeViewControllerProviderFactory: ViewControllerProviderFactory {

    // MARK: ViewControllerProviderFactory

    func createViewControllerProviders() -> [ViewControllerProvider] {
        var viewControllerProviders: [ViewControllerProvider] = []

        if let executablePath = Bundle.main.executablePath {
            var classCount: UInt32 = 0
            let classNames = objc_copyClassNamesForImage(executablePath, &classCount)
            if let classNames = classNames {
                for i in 0 ..< classCount {
                    let className = classNames[Int(i)]
                    let name = String.init(cString: className)

                    if let cls = NSClassFromString(name) as? (NSObject&ViewControllerProvider).Type {
                        let instance = cls.self.init()
                        viewControllerProviders.append(instance)
                    }
                }
            }

            free(classNames);
        }

        return viewControllerProviders
    }

}
