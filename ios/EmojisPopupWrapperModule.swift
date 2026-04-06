import ExpoModulesCore

public class EmojisPopupWrapperModule: Module {
  public func definition() -> ModuleDefinition {
    Name("EmojisPopupWrapper")

    View(ReactionPopupAnchorView.self) {
      Events([
        "onDragSelect",
        "onDragPlus",
        "onDragDismiss"
      ])

      Prop("anchorId") { (view: ReactionPopupAnchorView, anchorId: String) in
        view.anchorId = anchorId
      }

      Prop("gestureMode") { (view: ReactionPopupAnchorView, mode: String) in
        view.gestureMode = mode
      }

      Prop("dragParams") { (view: ReactionPopupAnchorView, params: [String: Any]?) in
        view.dragParams = params
      }
    }
  }
}
