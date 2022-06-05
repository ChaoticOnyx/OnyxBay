/* eslint-disable camelcase */
import { useBackend, useLocalState } from "../backend";
import {
  Button,
  Collapsible,
  ColorBox,
  Dropdown,
  Flex,
  Input,
  LabeledList,
  NumberInput,
  Tabs,
} from "../components";
import { Window } from "../layouts";
import uiGoon from "../assets/settings/ui-goon.png";
import uiMidnight from "../assets/settings/ui-midnight.png";
import uiMinimalist from "../assets/settings/ui-minimalist.png";
import uiOld from "../assets/settings/ui-old.png";
import uiOldNoborder from "../assets/settings/ui-old-noborder.png";
import uiOrange from "../assets/settings/ui-orange.png";
import uiWhite from "../assets/settings/ui-white.png";

const UI_IMAGE = {
  Goon: uiGoon,
  Midnight: uiMidnight,
  Orange: uiOrange,
  old: uiOld,
  White: uiWhite,
  "old-noborder": uiOldNoborder,
  minimalist: uiMinimalist,
};

const TABS = [
  {
    name: "Preferences",
    render: PreferencesTab,
  },
  {
    name: "UI",
    render: UiTab,
  },
];

type Preference = {
  description: string;
  key: string;
  category: string;
  options: string[];
  selectedOption: string;
};

type Theme = {
  name: string;
  selected: boolean;
};

type InputData = {
  preferences: Preference[];
  themes: Theme[];
  colorPicker?: string;
};

type PreferenceEntryProps = {
  preference: Preference;
};

type PreviewWindowProps = {
  uiStyle: string;
  uiAlpha: number;
  uiColor: string;
};

function PreviewWindow(props: PreviewWindowProps) {
  return (
    <div className="PreviewWindow">
      <div className="PreviewWindow-Background"></div>

      <svg
        className="PreviewWindow-Hud"
        xmlns="http://www.w3.org/2000/svg"
        version="1.1"
      >
        <defs>
          <filter id="colorMask">
            <feFlood floodColor={props.uiColor} result="flood" />
            <feComposite
              in="SourceGraphic"
              in2="flood"
              operator="arithmetic"
              k1="1"
              k2="0"
              k3="0"
              k4="0"
            />
          </filter>
        </defs>
        <image
          opacity={props.uiAlpha}
          width="100%"
          height="100%"
          xlinkHref={UI_IMAGE[props.uiStyle]}
          filter="url(#colorMask)"
        />
      </svg>
      <div className="PreviewWindow-Items"></div>
    </div>
  );
}

function PreferenceEntry(props: PreferenceEntryProps, context: any) {
  const { act } = useBackend<InputData>(context);
  const { preference } = props;

  return (
    <LabeledList.Item label={preference.description}>
      {preference.options.map((option) => (
        <Button
          key={option}
          onClick={() =>
            act("set_preference", {
              key: preference.key,
              value: option,
            })
          }
          className="Button--segmented PreferenceOption"
          selected={preference.selectedOption === option}
        >
          {option}
        </Button>
      ))}
    </LabeledList.Item>
  );
}

type PreferenceCategoryProps = {
  preferences: Preference[];
  category: string;
};

function PreferencesCategory(props: PreferenceCategoryProps, context: any) {
  return (
    <Collapsible
      className="PreferencesCategory"
      title={<b>{props.category}</b>}
    >
      <LabeledList>
        {props.preferences.map((preference) => (
          <PreferenceEntry key={preference.key} preference={preference} />
        ))}
      </LabeledList>
    </Collapsible>
  );
}

function rgbToHex(r: number, g: number, b: number): string {
  function toHex(num: number): string {
    const h = num.toString(16);
    return h.length === 1 ? `0${h}` : h;
  }

  return `#${toHex(r)}${toHex(g)}${toHex(b)}`;
}

function UiTab(props: any, context: any) {
  const { data, act } = useBackend<InputData>(context);
  const [style, setStyle] = useLocalState(context, "style", "Goon");
  const [colorR, setColorR] = useLocalState(context, "r", 255);
  const [colorG, setColorG] = useLocalState(context, "g", 255);
  const [colorB, setColorB] = useLocalState(context, "b", 255);
  const [alpha, setAlpha] = useLocalState(context, "alpha", 1.0);

  const hexColor = rgbToHex(colorR, colorG, colorB);

  return (
    <Flex direction="column">
      <Flex.Item align="center">
        <PreviewWindow uiColor={hexColor} uiAlpha={alpha} uiStyle={style} />
      </Flex.Item>
      <Flex.Item pt={1} width="480px" align="center">
        <LabeledList>
          <LabeledList.Item label="Theme">
            <Dropdown
              selected={style}
              options={data.themes.map((theme) => theme.name)}
              onSelected={(v) => setStyle(v)}
            />
          </LabeledList.Item>
          <LabeledList.Item label="Color (RGB)">
            <NumberInput
              value={colorR}
              minValue={0}
              maxValue={255}
              onDrag={(_, v) => setColorR(v)}
            />
            <NumberInput
              value={colorG}
              minValue={0}
              maxValue={255}
              onDrag={(_, v) => setColorG(v)}
            />
            <NumberInput
              value={colorB}
              minValue={0}
              maxValue={255}
              onDrag={(_, v) => setColorB(v)}
            />
            <ColorBox color={hexColor} />
          </LabeledList.Item>
          <LabeledList.Item label="Alpha">
            <NumberInput
              value={alpha}
              minValue={0.0}
              maxValue={1.0}
              step={0.1}
              stepPixelSize={10}
              onDrag={(_, v) => setAlpha(v)}
              format={(v) => v.toFixed(2)}
            />
          </LabeledList.Item>
        </LabeledList>
        <Button
          mt={1}
          onCLick={() =>
            act("set_ui", {
              style,
              color: hexColor,
              // Normalize in range between 0 and 255
              alpha: ((alpha - 0) / (1 - 0)) * (255 - 0) + 0,
            })
          }
        >
          Apply
        </Button>
      </Flex.Item>
    </Flex>
  );
}

function PreferencesTab(props: any, context: any) {
  const { data } = useBackend<InputData>(context);
  const preferencesPerCategory = {};

  for (const preference of data.preferences) {
    if (!(preference.category in preferencesPerCategory)) {
      preferencesPerCategory[preference.category] = [];
    }

    preferencesPerCategory[preference.category].push(preference);
  }

  return Object.keys(preferencesPerCategory)
    .sort()
    .map((category) => {
      const preferences = preferencesPerCategory[category];

      return (
        <PreferencesCategory
          key={category}
          preferences={preferences}
          category={category}
        />
      );
    });
}

export function PlayerSettings(props: any, context: any) {
  const { getTheme } = useBackend<InputData>(context);
  const [selectedTab, setSelectedTab] = useLocalState(
    context,
    "selectedTab",
    TABS[0].name
  );

  return (
    <Window theme={getTheme("neutral")} width={700} height={800}>
      <Window.Content className="SettingsWindow" scrollable>
        <Tabs fluid>
          {TABS.map((tab) => (
            <Tabs.Tab
              key={tab.name}
              onClick={() => setSelectedTab(tab.name)}
              selected={selectedTab === tab.name}
            >
              <b>{tab.name}</b>
            </Tabs.Tab>
          ))}
        </Tabs>
        {TABS.find((tab) => tab.name === selectedTab).render(props, context)}
      </Window.Content>
    </Window>
  );
}
