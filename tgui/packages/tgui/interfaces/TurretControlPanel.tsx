import { useBackend, useLocalState } from "../backend";
import { Button, Section, Stack } from "../components";
import { Window } from "../layouts";
import { Turret, TurretTargeting, turretTargetProps } from "./Turret";
import { TurretSettings, turretSettingsProps } from "./Turret";

enum Tab {
  Targeting,
  Settings,
}

interface Turret extends turretSettingsProps {}

export interface InputData extends turretTargetProps {
  page: number;
  turrets: Turret[];
  enabled: boolean;
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
            <Stack vertical>
              {data.turrets.map((turret: Turret) => (
                <TurretSettings
                  props={turret}
                  data={turret}
                  children={turret}
                />
              ))}
            </Stack>
          )) ||
            (currentTab === Tab.Targeting && <TurretTargeting />)}
        </Section>
      </Window.Content>
    </Window>
  );
};
