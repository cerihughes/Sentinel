import Foundation

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
