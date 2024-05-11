import { useBackend } from "../backend";
import { Window } from "../layouts";
import {
  Box,
  Section,
  Stack,
  LabeledList,
  Button,
  Divider,
  LabeledControls,
} from "../components";

interface Implant {
  implantee: string;
  ref: string;
  location: string;
  id: number;
  remainingUnits: number;
  coordinates: string;
}

interface InputData {
  chemImplants: Implant[];
  trackingImplants: Implant[];
}

export const PrisonerImplantManager = (props: any, context: any) => {
  const { act, data } = useBackend<InputData>(context);
  const { trackingImplants, chemImplants } = data;

  return (
    <Window width={540} height={320}>
      <Window.Content>
        <Stack fill>
          <Stack.Item grow>
            <Section fill scrollable title="Chemical Implants">
              {chemImplants?.length ? (
                <Stack fill vertical>
                  {chemImplants?.map((implant) => (
                    <Stack.Item grow>
                      <Box p={1} backgroundColor={"rgba(255, 255, 255, 0.05)"}>
                        <Box bold>Subject: {implant.implantee}</Box>
                        <Box key={implant.implantee}>
                          <br />
                          <LabeledList>
                            <LabeledList.Item label="Remaining Units">
                              {implant.remainingUnits} u.
                            </LabeledList.Item>
                            <LabeledList.Divider />
                            <LabeledList.Item label="Inject chemicals">
                              <Button
                                disabled={implant.remainingUnits < 1}
                                onClick={() =>
                                  act("inject", { ref: implant.ref, amt: 1 })
                                }
                              >
                                1 u
                              </Button>
                              <Button
                                disabled={implant.remainingUnits < 5}
                                onClick={() =>
                                  act("inject", { ref: implant.ref, amt: 5 })
                                }
                              >
                                5 u
                              </Button>
                              <Button
                                disabled={implant.remainingUnits < 10}
                                onClick={() =>
                                  act("inject", { ref: implant.ref, amt: 10 })
                                }
                              >
                                10 u
                              </Button>
                            </LabeledList.Item>
                          </LabeledList>
                        </Box>
                      </Box>
                    </Stack.Item>
                  ))}
                </Stack>
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
                      No implants.
                    </Stack.Item>
                  </Stack>
                </>
              )}
            </Section>
          </Stack.Item>
          <Stack.Item grow>
            <Section fill scrollable title="Tracking Implants">
              {trackingImplants?.length ? (
                <Stack vertical>
                  {trackingImplants?.map((implant) => (
                    <Stack.Item grow>
                      <Box p={1} backgroundColor={"rgba(255, 255, 255, 0.05)"}>
                        <Box bold>Subject: {implant.implantee}</Box>
                        <Box key={implant.implantee}>
                          <br />
                          <LabeledList>
                            <LabeledList.Item label="ID">
                              {implant.id}
                            </LabeledList.Item>
                            <LabeledList.Item label="Location">
                              {implant.location}
                            </LabeledList.Item>
                            <LabeledList.Item label="Coordinates">
                              {implant.coordinates}
                            </LabeledList.Item>
                          </LabeledList>
                          <br />
                          <Button
                            fluid
                            color="danger"
                            textAlign="center"
                            onClick={() => act("warn", { ref: implant.ref })}
                          >
                            Warn
                          </Button>
                        </Box>
                      </Box>
                    </Stack.Item>
                  ))}
                </Stack>
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
                      No implants.
                    </Stack.Item>
                  </Stack>
                </>
              )}
            </Section>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};
