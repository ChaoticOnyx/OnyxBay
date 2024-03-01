import { BooleanLike } from "common/react";
import { useBackend, useLocalState } from "../backend";
import { Button, Section, Box, Stack } from "../components";
import { Window } from "../layouts";
import {
  Turret,
  TurretTargeting,
  TargetingData,
  SettingsData,
  GunData,
  TurretData,
  TurretSettings,
} from "./Turret";

interface TurretInfo {
  ref: string;
  gunData: GunData;
  settingsData: SettingsData;
}

interface InputData {
  isEnabled: BooleanLike;
  turrets: TurretInfo[];
  targetingData: TargetingData;
}

export const TurretControl = (props: any, context: any) => {
  const { act, data } = useBackend<InputData>(context);
  const { isEnabled, turrets, targetingData } = data;

  const [settingsOpen, setSettingsOpen] = useLocalState(
    context,
    "settingsOpen",
    false
  );

  const onToggleHandler = (action: string) => act("toggle", { check: action });

  return (
    <Window title="Turret Control Panel" width={300} height={355}>
      <Window.Content>
        <Stack fill vertical>
          <Stack.Item>
            <Section
              title="Turret Control Panel"
              fitted
              scrollable
              buttons={
                <>
                  <Button
                    icon={isEnabled ? "toggle-on" : "toggle-off"}
                    color={isEnabled ? "default" : "green"}
                    tooltip={`${data.turrets.length} turrets are ${
                      isEnabled ? "online" : "offline"
                    }`}
                    onClick={() => onToggleHandler("power")}
                  />
                  <Button
                    icon={"screwdriver-wrench"}
                    onClick={() => setSettingsOpen(!settingsOpen)}
                  />
                </>
              }
            />
          </Stack.Item>
          <Stack.Item grow>
            {settingsOpen ? (
              <Stack fill vertical overflowY="scroll">
                {turrets.map((turret, index) => (
                  <Stack.Item key={index} pr={1}>
                    <Section fill>
                      <TurretSettings
                        gun={turret.gunData}
                        settings={turret.settingsData}
                        onBearingClick={() =>
                          act("changeBearing", { ref: turret.ref })
                        }
                      />
                    </Section>
                  </Stack.Item>
                ))}
              </Stack>
            ) : (
              <TurretTargeting
                data={targetingData}
                onToggle={onToggleHandler}
              />
            )}
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};
