import { useBackend, useLocalState } from "../backend";
import { Button, Section, Box, Stack } from "../components";
import { Window } from "../layouts";
import { Turret, TurretTargeting, TargetingData, SettingsData } from "./Turret";
import { TurretSettings } from "./Turret";

enum Tab {
  Targeting,
  Settings,
}

interface Turret {
  turretSettings: SettingsData;
}

export interface InputData {
  turrets: Turret[];
  enabled: boolean;
  targetingData: TargetingData;
}

export const TurretControlPanel = (props: any, context: any) => {
  const { act, data } = useBackend<InputData>(context);
  const [currentTab, setCurrentTab] = useLocalState(
    context,
    "tabName",
    Tab.Targeting
  );

  return (
    <Window title="Turret Control Panel" width={240} height={295}>
      <Window.Content>
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
          <Button
            fluid
            icon={data.enabled ? "toggle-on" : "toggle-off"}
            color={data.enabled ? "default" : "green"}
            onClick={() => act("toggle", {})}
          >
            {data.turrets?.length} turrets are{" "}
            {data.enabled ? "online" : "offline"}
          </Button>
        </Section>
        <Section>
          {" "}
          {(currentTab === Tab.Settings && (
            <Stack overflowY="scroll" fill vertical>
              {data.turrets.map((turret) => (
                <Stack.Item>
                  <TurretSettings
                    params={turret.turretSettings}
                    onBearingChange={(value) =>
                      act("adjust_default_bearing", { new_bearing: value })
                    }
                  />
                </Stack.Item>
              ))}
            </Stack>
          )) ||
            (currentTab === Tab.Targeting && (
              <TurretTargeting
                params={data.targetingData}
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
      </Window.Content>
    </Window>
  );
};
