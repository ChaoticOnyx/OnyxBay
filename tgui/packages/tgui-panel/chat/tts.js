import { storage } from "common/storage";

export const TTS_STORAGE_KEY = "tts-settings";

const DEFAULT_TTS_SETTINGS = {
  enabled: false,
  volume: 0.5,
  rate: 1.0,
  pitch: 1.0,
  maleVoiceName: "",
  femaleVoiceName: "",
  unknownVoiceName: "",
  ttsMessageTypes: ["localchat", "radio"],
};

const SPEECH_EXTRACT_TYPES = ["localchat", "radio"];

class TtsEngine {
  constructor() {
    this.settings = { ...DEFAULT_TTS_SETTINGS };
    this.voices = [];
    this.voicesLoaded = false;
    this.synth =
      typeof window !== "undefined" && window.speechSynthesis
        ? window.speechSynthesis
        : null;

    if (this.synth) {
      this._loadVoices();
      if (this.synth.onvoiceschanged !== undefined) {
        this.synth.onvoiceschanged = () => this._loadVoices();
      }
    }

    this._loadSettingsFromStorage();
  }

  _loadVoices() {
    if (!this.synth) {
      return;
    }
    this.voices = this.synth.getVoices();
    this.voicesLoaded = this.voices.length > 0;
  }

  async _loadSettingsFromStorage() {
    try {
      const saved = await storage.get(TTS_STORAGE_KEY);
      if (saved) {
        this.settings = { ...DEFAULT_TTS_SETTINGS, ...saved };
      }
    } catch (_e) {
      // ignore
    }
  }

  async _saveSettingsToStorage() {
    try {
      await storage.set(TTS_STORAGE_KEY, this.settings);
    } catch (_e) {
      // ignore
    }
  }

  /**
   * Returns a copy of current settings.
   */
  getSettings() {
    return { ...this.settings };
  }

  /**
   * Partially updates settings and saves to storage.
   */
  updateSettings(partial) {
    this.settings = { ...this.settings, ...partial };
    this._saveSettingsToStorage();
  }

  /**
   * List of available browser voices.
   */
  getVoices() {
    if (!this.voicesLoaded && this.synth) {
      this._loadVoices();
    }
    return [...this.voices];
  }

  /**
   * Find a SpeechSynthesisVoice object by name.
   */
  getVoiceByName(name) {
    if (!name) {
      return null;
    }
    return this.voices.find((v) => v.name === name) || null;
  }

  /**
   * Get voice assigned to gender.
   * gender: "male" | "female" | any other → unknown.
   */
  getVoiceForGender(gender) {
    switch (gender) {
      case "male":
        return this.getVoiceByName(this.settings.maleVoiceName);
      case "female":
        return this.getVoiceByName(this.settings.femaleVoiceName);
      default:
        return this.getVoiceByName(this.settings.unknownVoiceName);
    }
  }

  /**
   * Whether Web Speech API is available in this browser.
   */
  isAvailable() {
    return !!this.synth;
  }

  /**
   * Whether TTS is enabled (and API is available).
   */
  isEnabled() {
    return this.settings.enabled && this.isAvailable();
  }

  /**
   * Extract plain text from HTML string.
   */
  extractTextFromHtml(html) {
    const div = document.createElement("div");
    div.innerHTML = html;
    return (div.textContent || div.innerText || "").trim();
  }

  /**
   * Extracts only spoken speech from message text.
   * Looks for text in quotes: "...", «...», „..."
   * If there are multiple quotes — concatenates all fragments.
   * If there are no quotes — returns the original text (for emotes, etc.)
   */
  extractSpeechContent(text) {
    // Collect all fragments in different quote types
    const fragments = [];

    // Standard double quotes "..."
    const standardRegex = /"([^"]+)"/g;
    let match;
    while ((match = standardRegex.exec(text)) !== null) {
      if (match[1].trim()) {
        fragments.push(match[1].trim());
      }
    }

    // If found — return
    if (fragments.length > 0) {
      return fragments.join(" ");
    }

    // Unicode quotes «...» and „..."
    const unicodeRegex = /[«„""]([^»""]+)[»""]/g;
    while ((match = unicodeRegex.exec(text)) !== null) {
      if (match[1].trim()) {
        fragments.push(match[1].trim());
      }
    }

    if (fragments.length > 0) {
      return fragments.join(" ");
    }

    // No quotes — return the whole text (emotes, etc.)
    return text;
  }

  speakMessage(message) {
    if (!this.isEnabled()) {
      return;
    }

    // Check that the message type is allowed for speech
    if (message.type && !this.settings.ttsMessageTypes.includes(message.type)) {
      return;
    }

    let text = "";
    if (message.text) {
      text = message.text;
    } else if (message.node) {
      text = (message.node.textContent || "").trim();
    } else if (message.html) {
      text = this.extractTextFromHtml(message.html);
    }

    if (!text) {
      return;
    }

    // For speech types, extract only text from quotes
    if (SPEECH_EXTRACT_TYPES.includes(message.type)) {
      text = this.extractSpeechContent(text);
    }

    if (!text) {
      return;
    }

    this.speak(text, message.gender || null);
  }

  /**
   * Speak text with a voice matching the gender.
   */
  speak(text, gender) {
    if (!this.isEnabled() || !text) {
      return;
    }

    const utterance = new SpeechSynthesisUtterance(text);

    const voice = this.getVoiceForGender(gender);
    if (voice) {
      utterance.voice = voice;
    }

    utterance.volume = this.settings.volume;
    utterance.rate = this.settings.rate;
    utterance.pitch = this.settings.pitch;

    this.synth.speak(utterance);
  }

  /**
   * Stop current and clear speech queue.
   */
  stop() {
    if (this.synth) {
      this.synth.cancel();
    }
  }
}

// Singleton, survives hot code replacement
if (!window.__ttsEngine__) {
  window.__ttsEngine__ = new TtsEngine();
}

/** @type {TtsEngine} */
export const ttsEngine = window.__ttsEngine__;
