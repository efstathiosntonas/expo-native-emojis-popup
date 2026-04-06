import ExpoModulesCore

public class ExpoNativeEmojisPopupModule: Module {
  public func definition() -> ModuleDefinition {
    Name("ExpoNativeEmojisPopup")

    AsyncFunction("show") { (params: [String: Any]) async throws -> [String: Any] in
      let showParams = try ReactionPopupShowParams(dictionary: params)
      return try await ReactionPopupOverlayPresenter.shared.show(params: showParams)
    }

    AsyncFunction("dismiss") { () async -> Void in
      await ReactionPopupOverlayPresenter.shared.dismiss()
    }
  }
}
