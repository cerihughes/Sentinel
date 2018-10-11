import Foundation

/**
 An implementation of ViewControllerProviderLoader which uses objc-runtime magic to find all loaded classes that
 implement ViewControllerProvider.
 */
class RuntimeViewControllerProviderLoader: ViewControllerProviderLoader {

    // MARK: ViewControllerProviderLoader

    func viewControllerProviderFactories() -> [ViewControllerProviderFactory.Type] {
        var viewControllerProviderFactories: [ViewControllerProviderFactory.Type] = []

        if let executablePath = Bundle.main.executablePath {
            var classCount: UInt32 = 0
            let classNames = objc_copyClassNamesForImage(executablePath, &classCount)
            if let classNames = classNames {
                for i in 0 ..< classCount {
                    let className = classNames[Int(i)]
                    let name = String.init(cString: className)
                    if let cls = NSClassFromString(name) as? ViewControllerProviderFactory.Type {
                        viewControllerProviderFactories.append(cls)
                    }
                }
            }

            free(classNames);
        }

        return viewControllerProviderFactories
    }

}
