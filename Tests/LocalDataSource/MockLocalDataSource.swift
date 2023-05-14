@testable import Sentinel

class MockLocalDataSource: LocalDataSource {
    var mockLocalStorage = MockLocalStorage()
    var localStorage: LocalStorage { mockLocalStorage }
}
