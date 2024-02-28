import { useBackend, useLocalState } from "../backend";
import {
  Button,
  Section,
  NoticeBox,
  Stack,
  LabeledList,
  ProgressBar,
  NumberInput,
} from "../components";
import { Window } from "../layouts";

enum Tab {
  Targeting,
  Settings,
}

export interface SettingsData {
  gun: string;
  status: boolean;
  integrity: number;
  maxIntegrity: number;
  gunAmmo: number;
  gunMaxAmmo: number;
  storedAmmo: number;
  currentBearing: number;
  defaultBearing: number;
}

export interface TargetingData {
  lethalMode: boolean;
  checkSynth: boolean;
  checkWeapon: boolean;
  checkRecords: boolean;
  checkArrests: boolean;
  checkAccess: boolean;
  checkAnomalies: boolean;
}

export interface InputData {
  masterController: boolean;
  isMalf: boolean;
  signalerInstalled: boolean;
  enabled: boolean;
  settingsData: SettingsData;
  targettingData: TargetingData;
}

export const Turret = (props: any, context: any) => {
  const { act, data } = useBackend<InputData>(context);
  const [currentTab, setCurrentTab] = useLocalState(
    context,
    "tabName",
    Tab.Targeting
  );

  return (
    <Window title="Turret Panel" width={240} height={290}>
      <Window.Content scrollable>
        <Section
          title="Turret Control Panel"
          buttons={
            <Button
              icon={"screwdriver-wrench"}
              tooltip={"Manage turrets"}
              onClick={() =>
                setCurrentTab(currentTab ? Tab.Targeting : Tab.Settings)
              }
            />
          }
        >
          {!data.isMalf ? (
            <></>
          ) : (
            <Button
              fluid
              color={"bad"}
              icon={"plug-circle-xmark"}
              disabled={!data.signalerInstalled}
              tooltip={
                "Fries this turret's signaler, breaking connection with its remote control panel."
              }
              onClick={() => act("destroy_signaler")}
            >
              Destroy signaler
            </Button>
          )}
        </Section>
        {data.masterController ? (
          <NoticeBox>Turret is remotely controlled.</NoticeBox>
        ) : (
          <Section>
            {(currentTab === Tab.Settings && (
              <TurretSettings
                params={data.settingsData}
                onBearingChange={(value) =>
                  act("adjust_default_bearing", { new_bearing: value })
                }
              />
            )) ||
              (currentTab === Tab.Targeting && (
                <TurretTargeting
                  params={data.targettingData}
                  lethalModeSwitch={() => act("lethal_mode")}
                  synthSwitch={() => act("check_synth")}
                  weaponSwitch={() => act("check_weapon")}
                  recordsSwitch={() => act("check_records")}
                  arrestSwitch={() => act("check_arrest")}
                  accessSwitch={() => act("check_access")}
                  anomaliesSwitch={() => act("check_anomalies")}
                />
              ))}
          </Section>
        )}
      </Window.Content>
    </Window>
  );
};

interface TurretSettingsProps {
  params: SettingsData;
  onBearingChange: (value: number) => void;
}

export const TurretSettings = (props: TurretSettingsProps, context: any) => {
  const { params, onBearingChange } = props;
  const {
    gun,
    status,
    integrity,
    maxIntegrity,
    gunAmmo,
    gunMaxAmmo,
    storedAmmo,
    currentBearing,
    defaultBearing,
  } = params;

  return (
    <>
      <LabeledList>
        <LabeledList.Item label="Installed gun">{gun}</LabeledList.Item>
        <LabeledList.Item label="Integrity">
          <ProgressBar
            value={integrity}
            minValue={0}
            maxValue={maxIntegrity}
            ranges={{
              bad: [-Infinity, 0.7],
              average: [0.7, 0.9],
              good: [0.9, Infinity],
            }}
          />
        </LabeledList.Item>
        <LabeledList.Item label="Ammo">
          <ProgressBar
            value={gunAmmo}
            minValue={0}
            maxValue={gunMaxAmmo}
            ranges={{
              bad: [-Infinity, 0.7],
              average: [0.7, 0.9],
              good: [0.9, Infinity],
            }}
          />
        </LabeledList.Item>
        <LabeledList.Item label="Default bearing">
          <NumberInput
            inline
            size={1}
            step={1}
            stepPixelSize={2}
            value={defaultBearing}
            minValue={0}
            maxValue={360}
            bipolar={true}
            onChange={(e: any, value: number) => onBearingChange(value)}
          />
        </LabeledList.Item>
        <LabeledList.Item label="Current bearing">
          {currentBearing}
        </LabeledList.Item>
      </LabeledList>
      <LabeledList.Divider size={1} />
    </>
  );
};

interface TurgetTargetingProps {
  params: TargetingData;
  lethalModeSwitch: () => void;
  synthSwitch: () => void;
  weaponSwitch: () => void;
  recordsSwitch: () => void;
  arrestSwitch: () => void;
  accessSwitch: () => void;
  anomaliesSwitch: () => void;
}

export const TurretTargeting = (props: TurgetTargetingProps, context: any) => {
  const {
    params,
    lethalModeSwitch,
    synthSwitch,
    weaponSwitch,
    recordsSwitch,
    arrestSwitch,
    accessSwitch,
    anomaliesSwitch,
  } = props;
  const {
    lethalMode,
    checkSynth,
    checkWeapon,
    checkRecords,
    checkArrests,
    checkAccess,
    checkAnomalies,
  } = params;

  return (
    <Section>
      <Stack.Item>
        <Stack>
          <Stack.Item align="right">
            <Button
              fluid
              content={"Lethal Mode"}
              icon={lethalMode ? "circle-check" : "circle"}
              color={lethalMode ? "red" : "green"}
              onClick={() => lethalModeSwitch()}
            />
            <Button
              fluid
              content={"Neutralize ALL Non-Synthetics"}
              icon={checkSynth ? "circle-check" : "circle"}
              color={checkSynth ? "red" : "green"}
              onClick={() => synthSwitch()}
            />
            <Button
              fluid
              content={"Check Weapon Authorization"}
              icon={checkWeapon ? "circle-check" : "circle"}
              color={checkWeapon ? "red" : "green"}
              onClick={() => weaponSwitch()}
            />
            <Button
              fluid
              content={"Check Security Records"}
              icon={checkRecords ? "circle-check" : "circle"}
              color={checkRecords ? "red" : "green"}
              onClick={() => recordsSwitch()}
            />
            <Button
              fluid
              content={"Check Arrest Status"}
              icon={checkArrests ? "circle-check" : "circle"}
              color={checkArrests ? "red" : "green"}
              onClick={() => arrestSwitch()}
            />
            <Button
              fluid
              content={"Check Access Authorization"}
              icon={checkAccess ? "circle-check" : "circle"}
              color={checkAccess ? "red" : "green"}
              onClick={() => accessSwitch()}
            />
            <Button
              fluid
              content={"Check misc. Lifeforms"}
              icon={checkAnomalies ? "circle-check" : "circle"}
              color={checkAnomalies ? "red" : "green"}
              onClick={() => anomaliesSwitch()}
            />
          </Stack.Item>
        </Stack>
      </Stack.Item>
    </Section>
  );
};
