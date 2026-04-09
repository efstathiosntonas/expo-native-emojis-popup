package expo.modules.nativeemojispopup

import expo.modules.kotlin.modules.Module
import expo.modules.kotlin.modules.ModuleDefinition

class EmojisPopupWrapperModule : Module() {
  override fun definition() =
    ModuleDefinition {
      Name("EmojisPopupWrapper")

      View(EmojisPopupWrapper::class) {
        Events(arrayOf("onDragSelect", "onDragPlus", "onDragDismiss", "onTap"))

        Prop("anchorId") { view: EmojisPopupWrapper, anchorId: String ->
          view.anchorId = anchorId
        }

        Prop("gestureMode") { view: EmojisPopupWrapper, mode: String ->
          view.gestureMode = mode
        }

        Prop("dragParams") { view: EmojisPopupWrapper, params: Map<String, Any?>? ->
          view.dragParams = params
        }
      }
    }
}
