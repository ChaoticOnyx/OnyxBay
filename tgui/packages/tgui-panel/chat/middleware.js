/* eslint-disable no-undef */
/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

import DOMPurify from "dompurify";
import { storage } from "common/storage";
import { loadSettings, updateSettings } from "../settings/actions";
import { selectSettings } from "../settings/selectors";
import {
  addChatPage,
  changeChatPage,
  changeScrollTracking,
  loadChat,
  loadSettingsFromDisk,
  rebuildChat,
  removeChatPage,
  saveChatToDisk,
  saveSettingsToDisk,
  toggleAcceptedType,
  updateMessageCount,
} from "./actions";
import {
  MAX_PERSISTED_MESSAGES,
  MESSAGE_SAVE_INTERVAL,
  MESSAGE_TYPE_INTERNAL,
} from "./constants";
import { createMessage, serializeMessage } from "./model";
import { chatRenderer } from "./renderer";
import { selectChat, selectCurrentChatPage } from "./selectors";

// List of blacklisted tags
const FORBID_TAGS = ["a", "iframe", "link", "video"];

const saveChatToStorage = async (store) => {
  const state = selectChat(store.getState());
  const fromIndex = Math.max(
    0,
    chatRenderer.messages.length - MAX_PERSISTED_MESSAGES
  );
  const messages = chatRenderer.messages
    .slice(fromIndex)
    .map((message) => serializeMessage(message));
  storage.set("chat-state", state);
  storage.set("chat-messages", messages);
};

const loadChatFromStorage = async (store) => {
  const [state, messages] = await Promise.all([
    storage.get("chat-state"),
    storage.get("chat-messages"),
  ]);
  // Discard incompatible versions
  if (state && state.version <= 4) {
    store.dispatch(loadChat());
    return;
  }
  if (messages) {
    for (const message of messages) {
      if (message.html) {
        message.html = DOMPurify.sanitize(message.html, {
          FORBID_TAGS,
        });
      }
    }
    const batch = [
      ...messages,
      createMessage({
        type: "internal/reconnected",
      }),
    ];
    chatRenderer.processBatch(batch, {
      prepend: true,
    });
  }
  store.dispatch(loadChat(state));
};

const _saveSettingsToDisk = async () => {
  const data = {
    "chat-state": await storage.get("chat-state"),
    "panel-settings": await storage.get("panel-settings"),
    "spellchecker-settings": await storage.get("spellchecker-settings"),
  };

  const rawData = JSON.stringify(data);
  const blob = new Blob([rawData], { type: "application/json" });
  window.navigator.msSaveBlob(blob, "tgui-settings.json");
};

const _loadSettingsFromDisk = (data) => {
  const settings = JSON.parse(data);

  for (const key of Object.keys(settings)) {
    storage.set(key, settings[key]);
  }

  Byond.winset({
    command: "Nuke-Chat",
  });
};

export const chatMiddleware = (store) => {
  let initialized = false;
  let loaded = false;
  chatRenderer.events.on("batchProcessed", (countByType) => {
    // Use this flag to workaround unread messages caused by
    // loading them from storage. Side effect of that, is that
    // message count can not be trusted, only unread count.
    if (loaded) {
      store.dispatch(updateMessageCount(countByType));
    }
  });
  chatRenderer.events.on("scrollTrackingChanged", (scrollTracking) => {
    store.dispatch(changeScrollTracking(scrollTracking));
  });
  setInterval(() => saveChatToStorage(store), MESSAGE_SAVE_INTERVAL);
  return (next) => (action) => {
    const { type, payload } = action;
    if (!initialized) {
      initialized = true;
      loadChatFromStorage(store);
    }
    if (type === "chat/message") {
      // Normalize the payload
      const batch = Array.isArray(payload) ? payload : [payload];
      chatRenderer.processBatch(batch);
      return;
    }
    if (type === loadChat.type) {
      next(action);
      const page = selectCurrentChatPage(store.getState());
      chatRenderer.changePage(page);
      chatRenderer.onStateLoaded();
      loaded = true;
      return;
    }
    if (
      type === changeChatPage.type ||
      type === addChatPage.type ||
      type === removeChatPage.type ||
      type === toggleAcceptedType.type
    ) {
      next(action);
      const page = selectCurrentChatPage(store.getState());
      chatRenderer.changePage(page);
      return;
    }
    if (type === rebuildChat.type) {
      chatRenderer.rebuildChat();
      return next(action);
    }
    if (type === updateSettings.type || type === loadSettings.type) {
      next(action);
      const settings = selectSettings(store.getState());
      try {
        chatRenderer.setHighlight(
          settings.highlightText,
          settings.highlightColor
        );
      } catch (error) {
        store.dispatch({
          type: "chat/message",
          payload: {
            type: MESSAGE_TYPE_INTERNAL,
            text: `Incorrect or unsupported regular expression: ${error}`,
          },
        });
      }

      return;
    }
    if (type === "roundrestart") {
      // Save chat as soon as possible
      saveChatToStorage(store);
      return next(action);
    }
    if (type === saveChatToDisk.type) {
      chatRenderer.saveToDisk();
      return;
    }
    if (type === saveSettingsToDisk.type) {
      _saveSettingsToDisk();
      return;
    }
    if (type === loadSettingsFromDisk.type) {
      try {
        _loadSettingsFromDisk(payload.data);
      } catch (error) {
        store.dispatch({
          type: "chat/message",
          payload: {
            type: MESSAGE_TYPE_INTERNAL,
            text: `Invalid JSON data: ${error}`,
          },
        });
      }

      return;
    }
    return next(action);
  };
};
