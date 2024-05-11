import { toTitleCase } from "common/string";
import { useBackend } from "../backend";
import {
  Box,
  Button,
  Divider,
  Dropdown,
  Stack,
  LabeledList,
  NoticeBox,
  ProgressBar,
  Section,
} from "../components";
import { Window } from "../layouts";

export const DroneConsole = (props, context) => {
  return (
    <Window width={420} height={500}>
      <Window.Content>
        <Stack fill vertical>
          <Fabricator />
          <DroneList />
        </Stack>
      </Window.Content>
    </Window>
  );
};

interface Drone {
  name: string;
  ref: string;
  stat: number;
  client: boolean;
  health: number;
  charge: number;
  location: string;
}

interface DroneConsoleData {
  drone_fab: boolean;
  fab_power: boolean;
  drone_prod: boolean;
  drone_progress: number;
  drones: Drone[];
  area_list: String[];
  selected_area: string;
  ping_cd: number;
}

const Fabricator = (props, context) => {
  const { act, data } = useBackend<DroneConsoleData>(context);
  const { drone_fab, fab_power, drone_prod, drone_progress } = data;

  let FabDetected = () => {
    if (drone_fab) {
      return (
        <LabeledList>
          <LabeledList.Item label="External Power">
            <Box color={fab_power ? "good" : "bad"}>
              [ {fab_power ? "Online" : "Offline"} ]
            </Box>
          </LabeledList.Item>
          <LabeledList.Item label="Drone Production">
            <ProgressBar
              value={drone_progress / 100}
              ranges={{
                good: [0.7, Infinity],
                average: [0.4, 0.7],
                bad: [-Infinity, 0.4],
              }}
            />
          </LabeledList.Item>
        </LabeledList>
      );
    } else {
      return (
        <NoticeBox textAlign="center" danger={1}>
          <Stack inline={1} direction="column">
            <Stack.Item>FABRICATOR NOT DETECTED.</Stack.Item>
            <Stack.Item>
              <Button
                icon="search"
                content="Search"
                onClick={() => act("find_fab")}
              />
            </Stack.Item>
          </Stack>
        </NoticeBox>
      );
    }
  };

  return (
    <Section
      title="Drone Fabricator"
      buttons={
        <Button
          icon="power-off"
          content={drone_prod ? "Online" : "Offline"}
          color={drone_prod ? "green" : "red"}
          onClick={() => act("toggle_fab")}
        />
      }
    >
      {FabDetected()}
    </Section>
  );
};

const DroneList = (props: any, context: any) => {
  const { act, data } = useBackend<DroneConsoleData>(context);
  const { drones, area_list, selected_area, ping_cd } = data;

  let status = (stat, client) => {
    let box_color;
    let text;
    if (stat === 2) {
      // Dead
      box_color = "bad";
      text = "Disabled";
    } else if (stat === 1 || !client) {
      // Unconscious or SSD
      box_color = "average";
      text = "Inactive";
    } else {
      // Alive
      box_color = "good";
      text = "Active";
    }
    return <Box color={box_color}>{text}</Box>;
  };

  return (
    <>
      <Section title="Maintenance Units">
        <Stack fill>
          <Stack.Item>Request Drone presence in area:</Stack.Item>
          <Stack.Item>
            <Dropdown
              fluid
              options={area_list}
              selected={selected_area}
              onSelected={(value) =>
                act("set_area", {
                  area: value,
                })
              }
            />
          </Stack.Item>
        </Stack>
        <Button
          content="Send Ping"
          icon="broadcast-tower"
          disabled={ping_cd || !drones.length}
          title={drones.length ? null : "No active drones!"}
          fluid={1}
          textAlign="center"
          py={0.4}
          mt={0.6}
          onClick={() => act("ping")}
        />
      </Section>
      <Section fill scrollable>
        {drones.map((drone) => (
          <Section
            key={drone.name}
            title={toTitleCase(drone.name)}
            buttons={
              <Stack>
                <Stack.Item>
                  <Button
                    icon="sync"
                    content="Resync"
                    disabled={drone.stat === 2}
                    onClick={() =>
                      act("resync", {
                        ref: drone.ref,
                      })
                    }
                  />
                </Stack.Item>
                <Stack.Item>
                  <Button.Confirm
                    icon="power-off"
                    content="Shutdown"
                    disabled={drone.stat === 2}
                    tooltipPosition="left"
                    color="bad"
                    onClick={() =>
                      act("shutdown", {
                        ref: drone.ref,
                      })
                    }
                  />
                </Stack.Item>
              </Stack>
            }
          >
            <LabeledList>
              <LabeledList.Item label="Status">
                {status(drone.stat, drone.client)}
              </LabeledList.Item>
              <LabeledList.Item label="Integrity">
                <ProgressBar
                  value={drone.health}
                  ranges={{
                    good: [0.7, Infinity],
                    average: [0.4, 0.7],
                    bad: [-Infinity, 0.4],
                  }}
                />
              </LabeledList.Item>
              <LabeledList.Item label="Charge">
                <ProgressBar
                  value={drone.charge}
                  ranges={{
                    good: [0.7, Infinity],
                    average: [0.4, 0.7],
                    bad: [-Infinity, 0.4],
                  }}
                />
              </LabeledList.Item>
              <LabeledList.Item label="Location">
                {drone.location}
              </LabeledList.Item>
            </LabeledList>
          </Section>
        ))}
      </Section>
    </>
  );
};
