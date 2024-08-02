import { useBackend } from "../backend";
import {
  Input,
  Tabs,
  Button,
  Section,
  Stack,
  LabeledList,
  NumberInput,
  Divider,
} from "../components";
import { Window } from "../layouts";
import { useLocalState } from "../backend";

interface Access {
  name: string;
  id: number;
  req: string;
  allowed: boolean;
}

interface Region {
  name: string;
  id: number;
  accesses: Access[];
}

interface Data {
  areas: Access[];
  showlogs: false;
  IssueLog: string[];
  scanName: string;
  giv_name: string;
  duration: number;
  reason: string;
  printmsg: string;
  canprint: boolean;
  regions: Region[];
  selectedAccess: string;
}

export const Guestpass = (props: any, context: any) => {
  const { act, data } = useBackend<Data>(context);

  const [currentPage, setCurrentPage] = useLocalState(
    context,
    "currentPage",
    0
  );

  const [name, setName] = useLocalState(context, "name", "");
  const [reason, setReason] = useLocalState(context, "reason", "");
  const [duration, setDuration] = useLocalState(context, "duration", 0);

  return (
    <Window width={435} height={675}>
      <Window.Content>
        <Stack fill vertical>
          <Stack.Item>
            <Tabs>
              <Tabs.Tab
                icon="id-card"
                selected={currentPage === 0}
                onClick={() => setCurrentPage(0)}
              >
                Issue Pass
              </Tabs.Tab>
              <Tabs.Tab
                icon="scroll"
                selected={currentPage === 1}
                onClick={() => setCurrentPage(1)}
              >
                Records ({data.IssueLog?.length})
              </Tabs.Tab>
            </Tabs>
          </Stack.Item>
          <Stack.Item>
            <Section title="Authorization">
              <LabeledList>
                <LabeledList.Item label="ID Card">
                  <Button
                    icon={data.scanName ? "eject" : "id-card"}
                    selected={data.scanName}
                    content={data.scanName ? data.scanName : "-----"}
                    tooltip={data.scanName ? "Eject ID" : "Insert ID"}
                    onClick={() => act("scan")}
                  />
                </LabeledList.Item>
              </LabeledList>
            </Section>
          </Stack.Item>
          <Stack.Item>
            {currentPage === 0 && (
              <Section title="Issue Guest Pass">
                <LabeledList>
                  <LabeledList.Item label="Issue To">
                    <Input
                      icon="pencil-alt"
                      content={data.giv_name ? data.giv_name : "-----"}
                      disabled={!data.scanName}
                      onChange={(_, value: string) => {
                        act("set_name", {
                          new_name: value,
                        });
                      }}
                    />
                  </LabeledList.Item>
                  <LabeledList.Item label="Reason">
                    <Input
                      icon="pencil-alt"
                      content={data.reason ? data.reason : "-----"}
                      disabled={!data.scanName}
                      onChange={(_, value: string) => {
                        act("set_reason", {
                          new_reason: value,
                        });
                      }}
                    />
                  </LabeledList.Item>
                  <LabeledList.Item label="Duration">
                    <NumberInput
                      icon="pencil-alt"
                      content={data.duration ? data.duration : "-----"}
                      disabled={!data.scanName}
                      unit="minutes"
                      minValue={0}
                      maxValue={30}
                      value={duration}
                      onChange={(_, value: number) => {
                        act("set_duration", {
                          new_duration: value,
                        });
                        setDuration(value);
                      }}
                    />
                  </LabeledList.Item>
                </LabeledList>
              </Section>
            )}
          </Stack.Item>
          {currentPage === 0 &&
            (!data.scanName ? (
              <Stack.Item grow>
                <Section fill>
                  <Stack fill>
                    <Stack.Item
                      bold
                      grow
                      fontSize={1.5}
                      textAlign="center"
                      align="center"
                      color="label"
                    >
                      Please, insert ID Card
                    </Stack.Item>
                  </Stack>
                </Section>
              </Stack.Item>
            ) : (
              <Stack.Item grow>
                <AirlockAccessList
                  regions={data.regions}
                  selectedList={data.areas}
                  accessMod={(id: number) =>
                    act("set", {
                      access: id,
                    })
                  }
                />
              </Stack.Item>
            ))}
          {currentPage === 1 && (
            <Stack.Item grow m={0}>
              <Section
                fill
                scrollable
                title="Issuance Log"
                buttons={
                  <Button
                    icon="print"
                    content={"Print"}
                    disabled={!data.scanName}
                    onClick={() => act("print")}
                  />
                }
              >
                {(data.IssueLog?.length && (
                  <LabeledList>
                    {data.IssueLog.map((a, i) => (
                      <LabeledList.Item key={i}>{a}</LabeledList.Item>
                    ))}
                  </LabeledList>
                )) || (
                  <Stack fill>
                    <Stack.Item
                      bold
                      grow
                      fontSize={1.5}
                      textAlign="center"
                      align="center"
                      color="label"
                    >
                      No logs
                    </Stack.Item>
                  </Stack>
                )}
              </Section>
            </Stack.Item>
          )}
        </Stack>
      </Window.Content>
    </Window>
  );
};

const diffMap = {
  0: {
    icon: "times-circle",
    color: "bad",
  },
  1: {
    icon: "stop-circle",
    color: null,
  },
  2: {
    icon: "check-circle",
    color: "good",
  },
};

const AirlockAccessList = (props: any, context: any) => {
  const { act, data } = useBackend<Data>(context);
  const [selectedRegionName, setSelectedRegionName] = useLocalState(
    context,
    "accessName",
    data.regions[0]?.name
  );
  const selectedAccess = data.regions.find(
    (region) => region.name === selectedRegionName
  );
  const selectedAccessEntries = selectedAccess?.accesses || [];

  const checkAccessIcon = (accesses: Access[]) => {
    let oneAccess = false;
    let oneInaccess = false;
    for (const element of accesses) {
      if (data.areas?.includes(element)) {
        oneAccess = true;
      } else {
        oneInaccess = true;
      }
    }
    if (!oneAccess && oneInaccess) {
      return 0;
    } else if (oneAccess && oneInaccess) {
      return 1;
    } else {
      return 2;
    }
  };

  return (
    <Section
      fill
      scrollable
      title="Access"
      buttons={
        <>
          <Button
            icon="check-double"
            content="Select All"
            color="good"
            onClick={() => act("select_all")}
          />
          <Button
            icon="undo"
            content="Deselect All"
            color="bad"
            onClick={() => act("deselect_all")}
          />
          <Button
            icon="id-card"
            content="Print Pass."
            onClick={() => act("issue")}
          />
        </>
      }
    >
      <Stack>
        <Stack.Item grow basis="25%">
          <Tabs vertical>
            {data.regions.map((access) => {
              const entries = access.accesses || [];
              const icon = diffMap[checkAccessIcon(entries)].icon;
              const color = diffMap[checkAccessIcon(entries)].color;
              return (
                <Tabs.Tab
                  key={access.name}
                  altSelection
                  color={color}
                  icon={icon}
                  selected={access.name === selectedRegionName}
                  onClick={() => setSelectedRegionName(access.name)}
                >
                  {access.name}
                </Tabs.Tab>
              );
            })}
          </Tabs>
        </Stack.Item>
        <Stack.Item>
          <Divider vertical />
        </Stack.Item>
        <Stack.Item grow basis="80%">
          <Stack mb={1}>
            <Stack.Item grow>
              <Button
                fluid
                icon="check"
                content="Select All In Region"
                color="good"
                onClick={() =>
                  act("select_region", { region: selectedAccess.id })
                }
              />
            </Stack.Item>
            <Stack.Item grow>
              <Button
                fluid
                icon="times"
                content="Deselect All In Region"
                color="bad"
                onClick={() =>
                  act("deselect_region", { region: selectedAccess.id })
                }
              />
            </Stack.Item>
          </Stack>
          {selectedAccessEntries.map((entry) => (
            <Button.Checkbox
              fluid
              key={entry.name}
              content={entry.name}
              checked={entry.req}
              disabled={!entry.allowed}
              onClick={() => act("select_access", { area: entry.id })}
            />
          ))}
        </Stack.Item>
      </Stack>
    </Section>
  );
};
