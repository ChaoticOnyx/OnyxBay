import {
  Box,
  Button,
  LabeledList,
  Section,
  Stack,
  NoticeBox,
} from "../components";
import { useBackend } from "../backend";
import { Window } from "../layouts";

type FaxInfo = {
  fax_name: string;
};

type InputData = {
  user: string;
  idCard: string;
  isAuthenticated: boolean;
  paper: string;
  printCooldown: number;
  canSend: boolean;
  faxes: FaxInfo[];
};

export const Fax = (props: any, context: any) => {
  const { act, data } = useBackend<InputData>(context);
  return (
    <Window width={290} height={390} title="Fax machine">
      <Window.Content>
        <Stack fill vertical>
          <Stack.Item>
            <Section title="Quantum Entanglement Network">
              <Stack fill>
                <Stack.Item grow>
                  <LabeledList.Item label="Identity">
                    <Button
                      fluid
                      align="center"
                      icon="id-card"
                      content={data.idCard || "--------"}
                      onClick={() => act("idInteract")}
                    />
                  </LabeledList.Item>
                  <LabeledList.Item label="Paper">
                    <Button
                      fluid
                      align="center"
                      icon="sheet-plastic"
                      content={data.paper || "--------"}
                      onClick={() => act("paperInteract")}
                    />
                  </LabeledList.Item>
                </Stack.Item>
              </Stack>
            </Section>
          </Stack.Item>
          <Stack.Item>
            {!data.isAuthenticated ? (
              <NoticeBox>
                Proper authentication is required to use this device.
              </NoticeBox>
            ) : (
              <>
                <Section title="Send">
                  <Stack>
                    <Stack.Item>
                      {!data.faxes.length ? (
                        <NoticeBox>No network connection!.</NoticeBox>
                      ) : (
                        <Box mx={1}>
                          {data.faxes.map((fax: FaxInfo) => (
                            <Button
                              title={fax.fax_name}
                              disabled={!data.paper || !data.canSend}
                              onClick={() =>
                                act("send", {
                                  destination: fax.fax_name,
                                })
                              }
                            >
                              {fax.fax_name}
                            </Button>
                          ))}
                        </Box>
                      )}
                    </Stack.Item>
                  </Stack>
                </Section>
                <Stack>
                  <Stack.Item grow>
                    <Button
                      fluid
                      bold
                      textAlign="center"
                      disabled={data.printCooldown > 0}
                      icon="print"
                      onClick={() => {
                        act("print_kit");
                      }}
                    >
                      Print complaint kit
                    </Button>
                  </Stack.Item>
                </Stack>
              </>
            )}
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};
