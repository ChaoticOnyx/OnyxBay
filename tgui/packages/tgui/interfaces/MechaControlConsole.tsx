import { useBackend } from "../backend";
import {
  Button,
  Stack,
  LabeledList,
  ProgressBar,
  Section,
  NoticeBox,
} from "../components";
import { Window } from "../layouts";
import { toTitleCase, decodeHtmlEntities } from "common/string";
import { useLocalState } from "../backend";
import { decode } from "punycode";

interface Message {
  time: string;
  message: string;
}

interface Beacon {
  name: string;
  cellCharge: number;
  integrity: number;
  integrityMax: number;
  airtank: number;
  pilot: string;
  location: string;
  equipment: string;
  cargo: number;
  cargoCapacity: number;
  ref: string;
  logs: Message[];
}

interface InputData {
  beacons: Beacon[];
}

export const MechaControlConsole = (props: InputData, context: any) => {
  const { act, data } = useBackend<InputData>(context);
  const { beacons } = data;
  const [currentBeaconLog, setCurrentBeaconLog] = useLocalState(
    context,
    "currentBeaconLog",
    null
  );

  return (
    <Window width={420} height={500}>
      <Window.Content scrollable>
        {beacons?.length ? (
          <>
            {currentBeaconLog ? (
              <Section
                key={currentBeaconLog.name}
                title={currentBeaconLog.name}
                buttons={
                  <Button
                    icon="x"
                    onClick={() => {
                      setCurrentBeaconLog(null);
                    }}
                  >
                    Close Log
                  </Button>
                }
              >
                <Stack vertical fill overflowY="scroll">
                  {currentBeaconLog.logs.map((message: Message) => (
                    <Stack.Item>
                      <i>{message.time}</i>{" "}
                      {decodeHtmlEntities(message.message)}
                    </Stack.Item>
                  ))}
                </Stack>
              </Section>
            ) : (
              <>
                {beacons.map((beacon) => (
                  <Section
                    key={beacon.name}
                    title={beacon.name}
                    buttons={
                      <>
                        <Button
                          icon="comment"
                          onClick={() =>
                            act("send_message", { mt_ref: beacon.ref })
                          }
                        >
                          Message
                        </Button>
                        <Button
                          icon="eye"
                          onClick={() => {
                            act("get_log", { mt_ref: beacon.ref }),
                              setCurrentBeaconLog(beacon);
                          }}
                        >
                          View Log
                        </Button>
                        <Button.Confirm
                          color="red"
                          content="Sabotage"
                          icon="bomb"
                          onClick={() => act("shock", { mt_ref: beacon.ref })}
                        />
                      </>
                    }
                  >
                    <LabeledList>
                      <LabeledList.Item label="Health">
                        <ProgressBar
                          ranges={{
                            good: [beacon.integrityMax * 0.75, Infinity],
                            average: [
                              beacon.integrityMax * 0.5,
                              beacon.integrityMax * 0.75,
                            ],
                            bad: [-Infinity, beacon.integrityMax * 0.5],
                          }}
                          value={beacon.integrity}
                          maxValue={beacon.integrityMax}
                        />
                      </LabeledList.Item>
                      <LabeledList.Item label="Cell Charge">
                        {(beacon?.cellCharge && (
                          <ProgressBar
                            ranges={{
                              good: [beacon.cellCharge * 0.75, Infinity],
                              average: [
                                beacon.cellCharge * 0.5,
                                beacon.cellCharge * 0.75,
                              ],
                              bad: [-Infinity, beacon.cellCharge * 0.5],
                            }}
                            value={beacon.cellCharge}
                            maxValue={beacon.cellCharge}
                          />
                        )) || <NoticeBox>No Cell Installed</NoticeBox>}
                      </LabeledList.Item>
                      <LabeledList.Item label="Air Tank">
                        {beacon.airtank}kPa
                      </LabeledList.Item>
                      <LabeledList.Item label="Pilot">
                        {beacon.pilot || "Unoccupied"}
                      </LabeledList.Item>
                      <LabeledList.Item label="Location">
                        {toTitleCase(beacon.location) || "Unknown"}
                      </LabeledList.Item>
                      <LabeledList.Item label="Active Equipment">
                        {beacon.equipment || "None"}
                      </LabeledList.Item>
                      {(beacon.cargoCapacity && (
                        <LabeledList.Item label="Cargo Space">
                          <ProgressBar
                            ranges={{
                              bad: [beacon.cargoCapacity * 0.75, Infinity],
                              average: [
                                beacon.cargoCapacity * 0.5,
                                beacon.cargoCapacity * 0.75,
                              ],
                              good: [-Infinity, beacon.cargoCapacity * 0.5],
                            }}
                            value={beacon.cargo}
                            maxValue={beacon.cargoCapacity}
                          />
                        </LabeledList.Item>
                      )) ||
                        null}
                    </LabeledList>
                  </Section>
                ))}
              </>
            )}
          </>
        ) : (
          <>
            <Stack fill>
              <Stack.Item
                bold
                grow
                fontSize={1.5}
                textAlign="center"
                align="center"
                color="red"
              >
                No beacons detected!
              </Stack.Item>
            </Stack>
          </>
        )}
      </Window.Content>
    </Window>
  );
};
