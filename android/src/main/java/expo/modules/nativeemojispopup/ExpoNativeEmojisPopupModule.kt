package expo.modules.nativeemojispopup

import expo.modules.kotlin.functions.Coroutine
import expo.modules.kotlin.modules.Module
import expo.modules.kotlin.modules.ModuleDefinition

class ExpoNativeEmojisPopupModule : Module() {
  override fun definition() =
    ModuleDefinition {
      Name("ExpoNativeEmojisPopup")

      AsyncFunction("show") Coroutine { params: Map<String, Any?> ->
        val showParams = ReactionPopupShowParams.fromMap(params)
        ReactionPopupPresenter.show(appContext.currentActivity, showParams)
      }

      AsyncFunction("dismiss") Coroutine { ->
        ReactionPopupPresenter.dismiss()
      }
    }
}
