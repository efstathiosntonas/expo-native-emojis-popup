import { requireNativeModule } from 'expo-modules-core';

import type {
  NativeReactionPopupCloseResult,
  NativeReactionPopupResult,
  ShowReactionPopupParams
} from './ExpoNativeEmojisPopup.types';

interface NativeEmojisPopupModule {
  dismiss(): Promise<void>;
  show(params: Omit<ShowReactionPopupParams, 'onOpen' | 'onClose'>): Promise<NativeReactionPopupResult>;
}

export interface EmojisPopupModuleType {
  dismiss(): Promise<void>;
  show(params: ShowReactionPopupParams): Promise<NativeReactionPopupResult>;
}

let cachedModule: NativeEmojisPopupModule | null = null;

function getModule(): NativeEmojisPopupModule {
  if (cachedModule == null) {
    cachedModule =
      requireNativeModule<NativeEmojisPopupModule>('ExpoNativeEmojisPopup');
  }

  return cachedModule;
}

function toCloseResult(result: NativeReactionPopupResult): NativeReactionPopupCloseResult {
  if (result.type === 'select') {
    return { type: 'select', id: result.id, cancelled: false };
  }
  if (result.type === 'plus') {
    return { type: 'plus', cancelled: false };
  }
  return { type: 'dismiss', cancelled: true };
}

const EmojisPopupModule: EmojisPopupModuleType = {
  dismiss() {
    return getModule().dismiss();
  },
  async show(params) {
    const { onOpen, onClose, ...nativeParams } = params;

    const showPromise = getModule().show(nativeParams);

    // Fire onOpen after the native call is dispatched.
    // The native presentation begins on the next main thread frame.
    onOpen?.();

    const result = await showPromise;

    onClose?.(toCloseResult(result));

    return result;
  }
};

export default EmojisPopupModule;
