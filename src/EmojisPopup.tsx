import React from 'react';

import { requireNativeViewManager } from 'expo-modules-core';

import type {
  DragDismissEvent,
  DragPlusEvent,
  DragSelectEvent,
  ShowReactionPopupParams,
  TapEvent
} from './ExpoNativeEmojisPopup.types';

export type EmojisPopupProps = {
  anchorId: string;
  children: React.ReactElement;
  dragParams?: Omit<ShowReactionPopupParams, 'onOpen' | 'onClose'>;
  gestureMode?: 'none' | 'longPressDrag';
  onDragDismiss?: (event: DragDismissEvent) => void;
  onDragPlus?: (event: DragPlusEvent) => void;
  onDragSelect?: (event: DragSelectEvent) => void;
  /** Fired when the user taps (shorter than long-press threshold) in
   *  longPressDrag mode. Use to open the modal popup imperatively. */
  onTap?: (event: TapEvent) => void;
};

type NativeViewProps = Omit<
  EmojisPopupProps,
  'children'
> & {
  collapsable?: boolean;
  children?: React.ReactNode;
};

let cachedView: React.ComponentType<NativeViewProps> | null = null;

function getNativeView() {
  if (cachedView == null) {
    cachedView =
      requireNativeViewManager<NativeViewProps>(
        'EmojisPopupWrapper'
      );
  }

  return cachedView;
}

export function EmojisPopup({
  anchorId,
  children,
  dragParams,
  gestureMode = 'none',
  onDragDismiss,
  onDragPlus,
  onDragSelect,
  onTap
}: EmojisPopupProps) {
  const NativeView = getNativeView();

  return (
    <NativeView
      anchorId={anchorId}
      collapsable={false}
      dragParams={gestureMode === 'longPressDrag' ? dragParams : undefined}
      gestureMode={gestureMode}
      onDragDismiss={onDragDismiss}
      onDragPlus={onDragPlus}
      onDragSelect={onDragSelect}
      onTap={onTap}
    >
      {children}
    </NativeView>
  );
}
