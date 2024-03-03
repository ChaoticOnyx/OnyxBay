import { BooleanLike } from "common/react";
import { useBackend, useLocalState } from "../backend";
import {
  Button,
  Section,
  NoticeBox,
  Stack,
  LabeledList,
  ProgressBar,
  Box,
} from "../components";
import { Window } from "../layouts";
import { toTitleCase } from "common/string";

export interface SettingsData {
  bearing: number;
  integrity: number;
  maxIntegrity: number;
}

export interface GunData {
  gunName: string;
  gunAmmo: number;
  gunMaxAmmo: number;
  storedAmmo: number;
}

export interface TargetingData {
  lethalMode: BooleanLike;
  checkSynth: BooleanLike;
  checkWeapon: BooleanLike;
  checkRecords: BooleanLike;
  checkAccess: BooleanLike;
  checkArrests: BooleanLike;
  checkAnomalies: BooleanLike;
}

export interface TurretData {
  isMalf: BooleanLike;
  isEnabled: BooleanLike;
  hasMaster: BooleanLike;
  hasSignaler: BooleanLike;
  gunData: GunData;
  settingsData: SettingsData;
  targettingData: TargetingData;
}

export const Turret = (props: any, context: any) => {
  const { data } = useBackend<TurretData>(context);

  return (
    <Window title="Turret Panel" width={300} height={260}>
      <Window.Content>
        <TurretDisplay turretData={data} />
      </Window.Content>
    </Window>
  );
};

export interface TurretDisplayProps {
  turretData: TurretData;
}

export const TurretDisplay = (props: TurretDisplayProps, context: any) => {
  const { act } = useBackend(context);
  const { turretData } = props;

  const { isMalf, isEnabled, hasMaster, hasSignaler } = turretData;

  const [settingsOpen, setSettingsOpen] = useLocalState(
    context,
    "settingsOpen",
    false
  );

  const onToggleHandler = (action: string) => act("toggle", { check: action });

  return (
    <Section
      fill
      title="Turret Control Panel"
      buttons={
        <>
          <Button
            icon={isEnabled ? "toggle-on" : "toggle-off"}
            color={isEnabled ? "default" : "green"}
            onClick={() => onToggleHandler("power")}
          />
          <Button
            icon={"screwdriver-wrench"}
            onClick={() => setSettingsOpen(!settingsOpen)}
          />
        </>
      }
    >
      {isMalf ? (
        <Button
          fluid
          color="bad"
          disabled={!hasSignaler}
          icon="plug-circle-xmark"
          content="Destroy Connection"
          tooltip="Fries turret's signaler, thus breaking connection with its remote control panel."
          onClick={() => act("destroySignaler")}
        />
      ) : null}
      <Stack fill vertical>
        {hasMaster ? (
          <NoticeBox>Turret is remotely controlled.</NoticeBox>
        ) : (
          <Stack.Item grow>
            {settingsOpen ? (
              <TurretSettings
                gun={turretData.gunData}
                settings={turretData.settingsData}
                onBearingClick={() => act("changeBearing")}
              />
            ) : (
              <TurretTargeting
                data={turretData.targettingData}
                onToggle={onToggleHandler}
              />
            )}
          </Stack.Item>
        )}
      </Stack>
    </Section>
  );
};

interface TurretSettingsProps {
  gun: GunData;
  settings: SettingsData;
  onBearingClick: () => void;
}

export const TurretSettings = (props: TurretSettingsProps, context: any) => {
  const { gun, settings, onBearingClick } = props;

  const { gunName, gunAmmo, gunMaxAmmo, storedAmmo } = gun;
  const { bearing, integrity, maxIntegrity } = settings;

  return (
    <LabeledList>
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
      <LabeledList.Divider size={1} />
      <LabeledList.Item label="Gun">{toTitleCase(gunName)}</LabeledList.Item>
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
      {storedAmmo > 0 && (
        <LabeledList.Item label="Magazines">storedAmmo</LabeledList.Item>
      )}
      <LabeledList.Divider size={1} />
      <LabeledList.Item label="Default bearing">
        <Button
          icon="pen"
          content={bearing !== 0 ? `${bearing}\u00B0` : "not set"}
          onClick={() => onBearingClick()}
        />
      </LabeledList.Item>
    </LabeledList>
  );
};

interface TurgetTargetingProps {
  data: TargetingData;
  onToggle: (action: string) => void;
}

export const TurretTargeting = (props: TurgetTargetingProps, context: any) => {
  const { data, onToggle } = props;
  const {
    lethalMode,
    checkSynth,
    checkWeapon,
    checkRecords,
    checkArrests,
    checkAccess,
    checkAnomalies,
  } = data;

  return (
    <Stack fill vertical>
      <Stack.Item>
        <Button
          fluid
          content={"Lethal Mode"}
          icon={!!lethalMode ? "circle-check" : "circle"}
          color={!!lethalMode ? "red" : "green"}
          onClick={() => onToggle("mode")}
        />
      </Stack.Item>
      <Stack.Item>
        <Button
          fluid
          content={"Neutralize ALL Non-Synthetics"}
          icon={checkSynth ? "circle-check" : "circle"}
          color={checkSynth ? "red" : "green"}
          onClick={() => onToggle("synth")}
        />
      </Stack.Item>
      <Stack.Item>
        <Button
          fluid
          content={"Check Weapon Authorization"}
          icon={checkWeapon ? "circle-check" : "circle"}
          color={checkWeapon ? "red" : "green"}
          onClick={() => onToggle("weapon")}
        />
      </Stack.Item>
      <Stack.Item>
        <Button
          fluid
          content={"Check Security Records"}
          icon={checkRecords ? "circle-check" : "circle"}
          color={checkRecords ? "red" : "green"}
          onClick={() => onToggle("records")}
        />
      </Stack.Item>
      <Stack.Item>
        <Button
          fluid
          content={"Check Arrest Status"}
          icon={checkArrests ? "circle-check" : "circle"}
          color={checkArrests ? "red" : "green"}
          onClick={() => onToggle("arrest")}
        />
      </Stack.Item>
      <Stack.Item>
        <Button
          fluid
          content={"Check Access Authorization"}
          icon={checkAccess ? "circle-check" : "circle"}
          color={checkAccess ? "red" : "green"}
          onClick={() => onToggle("access")}
        />
      </Stack.Item>
      <Stack.Item>
        <Button
          fluid
          content={"Check misc. Lifeforms"}
          icon={checkAnomalies ? "circle-check" : "circle"}
          color={checkAnomalies ? "red" : "green"}
          onClick={() => onToggle("anomalies")}
        />
      </Stack.Item>
    </Stack>
  );
};
