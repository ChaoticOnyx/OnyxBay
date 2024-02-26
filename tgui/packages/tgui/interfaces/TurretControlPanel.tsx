import { useBackend } from "../backend";
import { Button, Section, Stack } from "../components";
import { Window } from "../layouts";
import { TurretTargeting, turretTargetProps } from "./TurretTargeting";
import { TurretSettings, turretSettingsProps } from "./TurretSettings";

interface Turret extends turretSettingsProps {}

export interface InputData extends turretTargetProps {
  page: number;
  turrets: Turret[];
  enabled: boolean;
}

const mainPage = (props: any, context: any) => {
  const { act, data } = useBackend<InputData>(context);

  return <TurretTargeting />;
};

const turretPage = (props: any, context: any) => {
  const { act, data } = useBackend<InputData>(context);

  return (
    <Stack vertical>
      {data.turrets.map((turret) => (
        <TurretSettings data={turret} />
      ))}
    </Stack>
  );
};

const PAGES = {
  0: {
    render: mainPage,
  },
  1: {
    render: turretPage,
  },
};

export const TurretControlPanel = (props: any, context: any) => {
  const { act, data } = useBackend<InputData>(context);
  return (
    <Window title="Turret Control Panel" width={240} height={295}>
      <Window.Content scrollable>
        <Section
          title="Turret Control Panel"
          buttons={
            <Button
              icon={"screwdriver-wrench"}
              tooltip={"Manage turrets"}
              onClick={() => act("change_page", {})}
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
        <Section>{PAGES[data.page].render(props, context)}</Section>
      </Window.Content>
    </Window>
  );
};
