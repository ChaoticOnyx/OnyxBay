import { useBackend } from "../backend";
import { Button, Section, NoticeBox, Stack } from "../components";
import { Window } from "../layouts";
import { TurretTargeting, turretTargetProps } from "./TurretTargeting";
import { TurretSettings, turretSettingsProps } from "./TurretSettings";

export interface InputData extends turretTargetProps, turretSettingsProps {
  page: number;
  masterController: boolean;
  isMalf: boolean;
  signalerInstalled: boolean;
  enabled: boolean;
}

const targetPage = (props: any, context: any) => {
  const { act, data } = useBackend<InputData>(context);

  return <TurretTargeting />;
};

const settingsPage = (props: any, context: any) => {
  const { act, data } = useBackend<InputData>(context);

  return <TurretSettings />;
};

const PAGES = {
  0: {
    render: targetPage,
  },
  1: {
    render: settingsPage,
  },
};

export const TurretPanel = (props: any, context: any) => {
  const { act, data } = useBackend<InputData>(context);
  return (
    <Window title="Turret Panel" width={240} height={290}>
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
          <Section>{PAGES[data.page].render(props, context)}</Section>
        )}
      </Window.Content>
    </Window>
  );
};
