import UIKit
import Flutter
import AVFoundation

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {

    do {
      try AVAudioSession.sharedInstance().setCategory(.playAndRecord, options: [.defaultToSpeaker])
      try AVAudioSession.sharedInstance().setActive(true)
    } catch {
      print("Audio session error")
    }

    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}