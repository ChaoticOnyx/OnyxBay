/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

import { toFixed } from "common/math";
import { useLocalState } from "tgui/backend";
import { useDispatch, useSelector } from "common/redux";
import {
  Box,
  Button,
  ColorBox,
  Divider,
  Dropdown,
  Flex,
  Input,
  LabeledList,
  NumberInput,
  Section,
  Stack,
  Tabs,
  TextArea,
} from "tgui/components";
import { ChatPageSettings } from "../chat";
import { ttsEngine } from "../chat/tts";
import { MESSAGE_TYPES } from "../chat/constants";
import {
  loadSettingsFromDisk,
  rebuildChat,
  resetSettings,
  saveChatToDisk,
  saveSettingsToDisk,
  updateTtsSettings,
} from "../chat/actions";
import { THEMES } from "../themes";
import { changeSettingsTab, updateSettings } from "./actions";
import { FONTS, REPEAT_MODE, SETTINGS_TABS, SIZE_MODE } from "./constants";
import { selectActiveTab, selectSettings } from "./selectors";

export const SettingsPanel = (props, context) => {
  const activeTab = useSelector(context, selectActiveTab);
  const dispatch = useDispatch(context);
  return (
    <Stack fill>
      <Stack.Item>
        <Section fitted fill minHeight="8em">
          <Tabs vertical>
            {SETTINGS_TABS.map((tab) => (
              <Tabs.Tab
                key={tab.id}
                selected={tab.id === activeTab}
                onClick={() =>
                  dispatch(
                    changeSettingsTab({
                      tabId: tab.id,
                    }),
                  )
                }
              >
                {tab.name}
              </Tabs.Tab>
            ))}
          </Tabs>
        </Section>
      </Stack.Item>
      <Stack.Item grow={1} basis={0}>
        {activeTab === "general" && <SettingsGeneral />}
        {activeTab === "chatPage" && <ChatPageSettings />}
        {activeTab === "tts" && <TtsSettings />}
        {activeTab === "backgroundImage" && <BackgroundImageSettings />}
        {activeTab === "css" && <CustomCssSettings />}
      </Stack.Item>
    </Stack>
  );
};

export const SettingsGeneral = (props, context) => {
  const {
    theme,
    fontFamily,
    fontSize,
    lineHeight,
    highlightText,
    highlightColor,
  } = useSelector(context, selectSettings);

  const dispatch = useDispatch(context);
  const [freeFont, setFreeFont] = useLocalState(context, "freeFont", false);
  const [pastedJson, setPastedJson] = useLocalState(context, "pastedJson", "");

  return (
    <Section>
      <LabeledList>
        <LabeledList.Item label="Theme">
          <Dropdown
            selected={theme}
            options={THEMES}
            onSelected={(value) =>
              dispatch(
                updateSettings({
                  theme: value,
                }),
              )
            }
          />
        </LabeledList.Item>
        <LabeledList.Item label="Font style">
          <Stack inline align="baseline">
            <Stack.Item>
              {(!freeFont && (
                <Dropdown
                  selected={fontFamily}
                  options={FONTS}
                  onSelected={(value) =>
                    dispatch(
                      updateSettings({
                        fontFamily: value,
                      }),
                    )
                  }
                />
              )) || (
                <Input
                  value={fontFamily}
                  onChange={(e, value) =>
                    dispatch(
                      updateSettings({
                        fontFamily: value,
                      }),
                    )
                  }
                />
              )}
            </Stack.Item>
            <Stack.Item>
              <Button
                content="Custom font"
                icon={freeFont ? "lock-open" : "lock"}
                color={freeFont ? "good" : "bad"}
                ml={1}
                onClick={() => {
                  setFreeFont(!freeFont);
                }}
              />
            </Stack.Item>
          </Stack>
        </LabeledList.Item>
        <LabeledList.Item label="Font size">
          <NumberInput
            width="4em"
            step={1}
            stepPixelSize={10}
            minValue={8}
            maxValue={32}
            value={fontSize}
            unit="px"
            onChange={(e, value) =>
              dispatch(
                updateSettings({
                  fontSize: value,
                }),
              )
            }
          />
        </LabeledList.Item>
        <LabeledList.Item label="Line height">
          <NumberInput
            width="4em"
            step={0.01}
            stepPixelSize={2}
            minValue={0.8}
            maxValue={5}
            value={lineHeight}
            format={(value) => toFixed(value, 2)}
            onDrag={(e, value) =>
              dispatch(
                updateSettings({
                  lineHeight: value,
                }),
              )
            }
          />
        </LabeledList.Item>
        <LabeledList.Item label="Save Settings">
          <Button
            icon="download"
            onClick={() => dispatch(saveSettingsToDisk())}
          />
        </LabeledList.Item>
        <LabeledList.Item label="Load Settings">
          <Stack align="baseline">
            <Stack.Item grow>
              <Input
                onInput={(e, value) => setPastedJson(value)}
                fluid
                placeholder="Paste your JSON here"
              />
            </Stack.Item>
            <Stack.Item>
              <Button
                onClick={() =>
                  dispatch(
                    loadSettingsFromDisk({
                      data: pastedJson,
                    }),
                  )
                }
                icon="upload"
                content="Load"
              />
            </Stack.Item>
          </Stack>
        </LabeledList.Item>
      </LabeledList>
      <Divider />
      <Box>
        <Flex mb={1} color="label" align="baseline">
          <Flex.Item grow={1}>Highlight words (comma separated):</Flex.Item>
          <Flex.Item shrink={0}>
            <ColorBox mr={1} color={highlightColor} />
            <Input
              width="5em"
              monospace
              placeholder="#ffffff"
              value={highlightColor}
              onInput={(e, value) =>
                dispatch(
                  updateSettings({
                    highlightColor: value,
                  }),
                )
              }
            />
          </Flex.Item>
        </Flex>
        <TextArea
          height="3em"
          value={highlightText}
          onChange={(e, value) =>
            dispatch(
              updateSettings({
                highlightText: value,
              }),
            )
          }
        />
      </Box>
      <Divider hidden />
      <Box>
        <Button icon="check" onClick={() => dispatch(rebuildChat())}>
          Apply now
        </Button>
        <Box inline fontSize="0.9em" ml={1} color="label">
          Can freeze the chat for a while.
        </Box>
      </Box>
      <Divider />
      <Button icon="save" onClick={() => dispatch(saveChatToDisk())}>
        Save chat log
      </Button>
      <Button.Confirm
        icon="trash"
        color="red"
        onClick={() => dispatch(resetSettings())}
      >
        Reset Chat
      </Button.Confirm>
    </Section>
  );
};

export const TtsSettings = (props, context) => {
  const dispatch = useDispatch(context);

  const [settings, setSettings] = useLocalState(
    context,
    "ttsSettings",
    ttsEngine.getSettings(),
  );

  const [voiceList, setVoiceList] = useLocalState(
    context,
    "ttsVoiceList",
    ttsEngine.getVoices().map((v) => v.name),
  );

  const refreshVoices = () => {
    setVoiceList(ttsEngine.getVoices().map((v) => v.name));
  };

  const update = (partial) => {
    const next = { ...settings, ...partial };
    setSettings(next);
    dispatch(updateTtsSettings(partial));
  };

  const toggleMessageType = (msgType) => {
    const current = settings.ttsMessageTypes || [];
    const next = current.includes(msgType)
      ? current.filter((t) => t !== msgType)
      : [...current, msgType];
    update({ ttsMessageTypes: next });
  };

  if (!ttsEngine.isAvailable()) {
    return (
      <Section>
        <Box color="bad" fontSize="1.2em" textAlign="center" mt={2}>
          Text-to-Speech is not supported in this browser.
        </Box>
      </Section>
    );
  }

  const voiceOptions = ["(Default)", ...voiceList];

  return (
    <Section>
      <LabeledList>
        <LabeledList.Item label="Enable TTS">
          <Button.Checkbox
            checked={settings.enabled}
            onClick={() => update({ enabled: !settings.enabled })}
          >
            {settings.enabled ? "On" : "Off"}
          </Button.Checkbox>
        </LabeledList.Item>
        <LabeledList.Item label="Volume">
          <NumberInput
            width="5em"
            step={5}
            stepPixelSize={5}
            minValue={0}
            maxValue={100}
            value={Math.round(settings.volume * 100)}
            unit="%"
            onChange={(e, value) => update({ volume: value / 100 })}
          />
        </LabeledList.Item>
        <LabeledList.Item label="Speed">
          <NumberInput
            width="5em"
            step={0.1}
            stepPixelSize={5}
            minValue={0.1}
            maxValue={10}
            value={settings.rate}
            format={(v) => toFixed(v, 1)}
            onChange={(e, value) => update({ rate: value })}
          />
        </LabeledList.Item>
        <LabeledList.Item label="Pitch">
          <NumberInput
            width="5em"
            step={0.1}
            stepPixelSize={5}
            minValue={0}
            maxValue={2}
            value={settings.pitch}
            format={(v) => toFixed(v, 1)}
            onChange={(e, value) => update({ pitch: value })}
          />
        </LabeledList.Item>
      </LabeledList>
      <Divider />
      <Flex align="center" mb={1}>
        <Flex.Item grow={1}>
          <Box bold>Voices</Box>
        </Flex.Item>
        <Flex.Item>
          <Button icon="sync" onClick={refreshVoices}>
            Refresh
          </Button>
        </Flex.Item>
      </Flex>
      {voiceList.length === 0 ? (
        <Box color="average" mb={1}>
          No voices found. Try clicking Refresh.
        </Box>
      ) : (
        <LabeledList>
          <LabeledList.Item label="Male voice">
            <Dropdown
              width="15em"
              selected={settings.maleVoiceName || "(Default)"}
              options={voiceOptions}
              onSelected={(value) =>
                update({
                  maleVoiceName: value === "(Default)" ? "" : value,
                })
              }
            />
          </LabeledList.Item>
          <LabeledList.Item label="Female voice">
            <Dropdown
              width="15em"
              selected={settings.femaleVoiceName || "(Default)"}
              options={voiceOptions}
              onSelected={(value) =>
                update({
                  femaleVoiceName: value === "(Default)" ? "" : value,
                })
              }
            />
          </LabeledList.Item>
          <LabeledList.Item label="Other voice">
            <Dropdown
              width="15em"
              selected={settings.unknownVoiceName || "(Default)"}
              options={voiceOptions}
              onSelected={(value) =>
                update({
                  unknownVoiceName: value === "(Default)" ? "" : value,
                })
              }
            />
          </LabeledList.Item>
        </LabeledList>
      )}
      <Divider />
      <Box bold mb={1}>
        Message types to speak
      </Box>
      {MESSAGE_TYPES.filter(
        (typeDef) => !typeDef.important && !typeDef.type.startsWith("internal"),
      ).map((typeDef) => (
        <Button.Checkbox
          key={typeDef.type}
          checked={(settings.ttsMessageTypes || []).includes(typeDef.type)}
          onClick={() => toggleMessageType(typeDef.type)}
        >
          {typeDef.name}
        </Button.Checkbox>
      ))}
      <Divider />
      <Button
        icon="play"
        onClick={() =>
          ttsEngine.speak("This is a test of text to speech.", null)
        }
      >
        Test
      </Button>
      <Button
        icon="play"
        ml={1}
        onClick={() => ttsEngine.speak("This is a male voice test.", "male")}
      >
        Test Male
      </Button>
      <Button
        icon="play"
        ml={1}
        onClick={() =>
          ttsEngine.speak("This is a female voice test.", "female")
        }
      >
        Test Female
      </Button>
      <Button icon="stop" color="red" ml={1} onClick={() => ttsEngine.stop()}>
        Stop
      </Button>
    </Section>
  );
};

export const BackgroundImageSettings = (props, context) => {
  let { background } = useSelector(context, selectSettings);
  const dispatch = useDispatch(context);

  background ||= {
    url: null,
    opaque: 0,
    repeat: REPEAT_MODE.no,
    size: SIZE_MODE.contain,
  };

  const { url, opaque, repeat, size } = background;

  return (
    <Section>
      <LabeledList>
        <LabeledList.Item label="Image">
          <Input
            fluid
            placeholder="Paste URL"
            value={url}
            onChange={(e, value) =>
              dispatch(
                updateSettings({
                  background: {
                    ...background,
                    url: value,
                  },
                }),
              )
            }
          />
        </LabeledList.Item>
        <LabeledList.Item label="Opaque">
          <NumberInput
            minValue={0}
            maxValue={100}
            value={opaque}
            unit="%"
            onChange={(e, value) =>
              dispatch(
                updateSettings({
                  background: {
                    ...background,
                    opaque: value,
                  },
                }),
              )
            }
          />
        </LabeledList.Item>
        <LabeledList.Item label="Repeat">
          <Button.Checkbox
            content="No Repeat"
            checked={repeat === REPEAT_MODE.no}
            onClick={() =>
              dispatch(
                updateSettings({
                  background: {
                    ...background,
                    repeat: REPEAT_MODE.no,
                  },
                }),
              )
            }
          />
          <Button.Checkbox
            content="Repeat"
            checked={repeat === REPEAT_MODE.repeat}
            onClick={() =>
              dispatch(
                updateSettings({
                  background: {
                    ...background,
                    repeat: REPEAT_MODE.repeat,
                  },
                }),
              )
            }
          />
          <Button.Checkbox
            content="Repeat-X"
            checked={repeat === REPEAT_MODE.repeatx}
            onClick={() =>
              dispatch(
                updateSettings({
                  background: {
                    ...background,
                    repeat: REPEAT_MODE.repeatx,
                  },
                }),
              )
            }
          />
          <Button.Checkbox
            content="Repeat-Y"
            checked={repeat === REPEAT_MODE.repeaty}
            onClick={() =>
              dispatch(
                updateSettings({
                  background: {
                    ...background,
                    repeat: REPEAT_MODE.repeaty,
                  },
                }),
              )
            }
          />
        </LabeledList.Item>
        <LabeledList.Item label="Size">
          <Button.Checkbox
            content="Cover"
            checked={size === SIZE_MODE.cover}
            onClick={() =>
              dispatch(
                updateSettings({
                  background: {
                    ...background,
                    size: SIZE_MODE.cover,
                  },
                }),
              )
            }
          />
          <Button.Checkbox
            content="Contain"
            checked={size === SIZE_MODE.contain}
            onClick={() =>
              dispatch(
                updateSettings({
                  background: {
                    ...background,
                    size: SIZE_MODE.contain,
                  },
                }),
              )
            }
          />
        </LabeledList.Item>
      </LabeledList>
    </Section>
  );
};

export const CustomCssSettings = (props, context) => {
  const { customCss } = useSelector(context, selectSettings);
  const dispatch = useDispatch(context);

  return (
    <Section>
      <TextArea
        value={customCss}
        height="300px"
        placeholder="Enter CSS here (live mode)"
        onInput={(e, value) =>
          dispatch(
            updateSettings({
              customCss: value,
            }),
          )
        }
      />
    </Section>
  );
};
