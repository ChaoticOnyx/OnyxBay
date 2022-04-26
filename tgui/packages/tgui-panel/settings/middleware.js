/* eslint-disable no-undef */
/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

import { storage } from "common/storage";
import { setClientTheme } from "../themes";
import { loadSettings, updateSettings } from "./actions";
import { selectSettings } from "./selectors";
import { FONTS_DISABLED } from "./constants";
import { resetSettings } from "../chat/actions";

const setGlobalFontSize = (fontSize) => {
  document.documentElement?.style.setProperty("font-size", fontSize + "px");
  document.body?.style.setProperty("font-size", fontSize + "px");
};

const setGlobalFontFamily = (fontFamily) => {
  if (fontFamily === FONTS_DISABLED) fontFamily = null;

  document.documentElement?.style.setProperty(
    "font-family",
    `${fontFamily}, "apple color emoji", "segoe ui emoji", "segoe ui symbol"`
  );
  document.body?.style.setProperty(
    "font-family",
    `${fontFamily}, "apple color emoji", "segoe ui emoji", "segoe ui symbol"`
  );
};

const setBackgroundImage = (background) => {
  const { url, opaque, repeat, size } = background;

  const chat = document.querySelectorAll("#chatContainer")[0];
  const backgroundContainer = document.querySelectorAll("#imageContainer")[0];

  if (!chat || !backgroundContainer) {
    return;
  }

  if (!url) {
    chat.style.removeProperty("background-color");
    backgroundContainer.style.removeProperty("background-image");
  } else {
    chat.style.setProperty("background-color", "rgba(0, 0, 0, 0.0)");
    backgroundContainer.style.setProperty(
      "background-image",
      `url("${encodeURI(url)}")`
    );
    backgroundContainer.style.setProperty("opacity", opaque / 100);
    backgroundContainer.style.setProperty("background-repeat", repeat);
    backgroundContainer.style.setProperty("background-size", size);
  }
};

const setCustomCss = (cssContent) => {
  const cssNode = document.querySelectorAll("#customCss")[0];

  if (!cssNode) {
    const newNode = document.createElement("style");
    newNode.id = "customCss";
    newNode.textContent = cssContent;
    document.body.appendChild(newNode);
  } else {
    cssNode.textContent = cssContent;
  }
};

export const settingsMiddleware = (store) => {
  let initialized = false;
  return (next) => (action) => {
    const { type, payload } = action;
    if (!initialized) {
      initialized = true;
      storage.get("panel-settings").then((settings) => {
        store.dispatch(loadSettings(settings));
      });
    }
    if (type === updateSettings.type || type === loadSettings.type) {
      // Set client theme
      const theme = payload?.theme;
      if (theme) {
        setClientTheme(theme);
      }
      // Pass action to get an updated state
      next(action);
      const settings = selectSettings(store.getState());
      // Update global UI font size
      setGlobalFontSize(settings.fontSize);
      setGlobalFontFamily(settings.fontFamily);
      setBackgroundImage(settings.background);
      setCustomCss(settings.customCss);
      // Save settings to the web storage
      storage.set("panel-settings", settings);
      return;
    }

    if (type === resetSettings.type) {
      storage.clear();
      Byond.winset({
        command: "Nuke-Chat",
      });
    }

    return next(action);
  };
};
