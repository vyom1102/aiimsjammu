import Flutter
import UIKit
import XCTest

class RunnerTests: XCTestCase {

  func testSceneLifecycleConfiguration() throws {
    let bundle = Bundle.main
    let manifest = try XCTUnwrap(bundle.object(forInfoDictionaryKey: "UIApplicationSceneManifest") as? [String: Any])
    let configurations = try XCTUnwrap(manifest["UISceneConfigurations"] as? [String: Any])
    let scenes = try XCTUnwrap(configurations["UIWindowSceneSessionRoleApplication"] as? [[String: Any]])
    let scene = try XCTUnwrap(scenes.first)
    XCTAssertEqual(scene["UISceneDelegateClassName"] as? String, "FlutterSceneDelegate")
    XCTAssertEqual(scene["UISceneStoryboardFile"] as? String, "Main")
    XCTAssertNotNil(NSClassFromString("FlutterSceneDelegate"))
  }

}
