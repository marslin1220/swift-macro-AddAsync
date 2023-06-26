import AddAsync
import PromiseKit

struct AsyncFunctions {

    @AddAsync
    func test(arg1: String, arg2: Int) -> Promise<String> {
        .value("hello world!")
    }
}

func testing() async {
    do {
        let result = try await AsyncFunctions().test(arg1: "Blob", arg2: 12)
        if result == "hello world!" {
            print("success")
        } else {
            print("failed")
        }
    } catch {
        print("\(error)")
    }
}
