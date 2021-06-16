/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

import { toFixed } from 'common/math';
import { useLocalState } from 'tgui/backend';
import { useDispatch, useSelector } from 'common/redux';
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
} from 'tgui/components';
import { ChatPageSettings } from '../chat';
import {
  loadSettingsFromDisk,
  rebuildChat,
  resetSettings,
  saveChatToDisk,
  saveSettingsToDisk,
} from '../chat/actions';
import { THEMES } from '../themes';
import { changeSettingsTab, updateSettings } from './actions';
import { FONTS, SETTINGS_TABS } from './constants';
import { selectActiveTab, selectSettings } from './selectors';

export const SettingsPanel = (props, context) => {
  const activeTab = useSelector(context, selectActiveTab);
  const dispatch = useDispatch(context);
  return (
    <Stack fill>
      <Stack.Item>
        <Section fitted fill minHeight='8em'>
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
                }>
                {tab.name}
              </Tabs.Tab>
            ))}
          </Tabs>
        </Section>
      </Stack.Item>
      <Stack.Item grow={1} basis={0}>
        {activeTab === 'general' && <SettingsGeneral />}
        {activeTab === 'chatPage' && <ChatPageSettings />}
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
    iconSize,
    highlightText,
    highlightColor,
  } = useSelector(context, selectSettings);
  const dispatch = useDispatch(context);
  const [freeFont, setFreeFont] = useLocalState(context, 'freeFont', false);
  const [pastedJson, setPastedJson] = useLocalState(context, 'pastedJson', '');

  return (
    <Section>
      <LabeledList>
        <LabeledList.Item label='Theme'>
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
        <LabeledList.Item label='Font style'>
          <Stack inline align='baseline'>
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
                content='Custom font'
                icon={freeFont ? 'lock-open' : 'lock'}
                color={freeFont ? 'good' : 'bad'}
                ml={1}
                onClick={() => {
                  setFreeFont(!freeFont);
                }}
              />
            </Stack.Item>
          </Stack>
        </LabeledList.Item>
        <LabeledList.Item label='Font size'>
          <NumberInput
            width='4em'
            step={1}
            stepPixelSize={10}
            minValue={8}
            maxValue={32}
            value={fontSize}
            unit='px'
            format={(value) => toFixed(value)}
            onChange={(e, value) =>
              dispatch(
                updateSettings({
                  fontSize: value,
                }),
            )
            }
          />
        </LabeledList.Item>
        <LabeledList.Item label='Line height'>
          <NumberInput
            width='4em'
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
        <LabeledList.Item label='Save Settings'>
          <Button
            icon='download'
            onClick={() => dispatch(saveSettingsToDisk())}
          />
        </LabeledList.Item>
        <LabeledList.Item label='Load Settings'>
          <Stack align='baseline'>
            <Stack.Item grow>
              <Input
                onInput={(e, value) => setPastedJson(value)}
                fluid
                placeholder='Paste your JSON here'
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
                icon='upload'
                content='Load'
              />
            </Stack.Item>
          </Stack>
        </LabeledList.Item>
      </LabeledList>
      <Divider />
      <Box>
        <Flex mb={1} color='label' align='baseline'>
          <Flex.Item grow={1}>Highlight words (comma separated):</Flex.Item>
          <Flex.Item shrink={0}>
            <ColorBox mr={1} color={highlightColor} />
            <Input
              width='5em'
              monospace
              placeholder='#ffffff'
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
          height='3em'
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
      <Divider />
      <Box>
        <Button icon='check' onClick={() => dispatch(rebuildChat())}>
          Apply now
        </Button>
        <Box inline fontSize='0.9em' ml={1} color='label'>
          Can freeze the chat for a while.
        </Box>
      </Box>
      <Divider />
      <Button icon='save' onClick={() => dispatch(saveChatToDisk())}>
        Save chat log
      </Button>
      <Button.Confirm
        icon='trash'
        color='red'
        onClick={() => dispatch(resetSettings())}>
        Reset Chat
      </Button.Confirm>
    </Section>
  );
};
