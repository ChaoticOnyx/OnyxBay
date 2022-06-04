import { useBackend, useLocalState } from "../backend";
import { Button, Flex, LabeledList, Section, Tabs } from "../components";
import { Window } from "../layouts";

interface Access {
  name: string;
  id: number;
  req: number;
}

interface Region {
  name: string;
  accesses: Access[];
}

interface InputData {
  regions: Region[];
  oneAccess: number;
  locked: number;
  lockable: number;
}

export const AirlockElectronics = (props: any, context: any) => {
  const { act, data } = useBackend<InputData>(context);
  const regions = data.regions || [];
  const oneAccess = data.oneAccess;
  let accesses: Access[] = [];
  data.regions.map(
    (region) =>
      (accesses = accesses.concat(
        region.accesses.filter((access) => access.req !== 0)
      ))
  );

  return (
    <Window width={420} height={485}>
      <Window.Content scrollable fitted>
        <Section title="Main">
          <LabeledList>
            <LabeledList.Item label="Access Required">
              <Button
                icon={oneAccess ? "unlock" : "lock"}
                content={oneAccess ? "One" : "All"}
                onClick={() => act("one_access")}
              />
            </LabeledList.Item>
          </LabeledList>
        </Section>
        <AirlockAccessList
          regions={regions}
          selectedList={accesses}
          accessMod={(id: number) =>
            act("set", {
              access: id,
            })
          }
        />
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
  const {
    regions = [],
    selectedList = [],
    accessMod,
  }: {
    regions: Region[];
    selectedList: any[];
    accessMod: (id: number) => void;
  } = props;
  const [selectedRegionName, setSelectedRegionName] = useLocalState(
    context,
    "accessName",
    regions[0]?.name
  );
  const selectedAccess = regions.find(
    (region) => region.name === selectedRegionName
  );
  const selectedAccessEntries = selectedAccess?.accesses || [];

  const checkAccessIcon = (accesses: Access[]) => {
    let oneAccess = false;
    let oneInaccess = false;
    for (const element of accesses) {
      if (selectedList.includes(element)) {
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
    <Section title="Access" fill>
      <Flex>
        <Flex.Item>
          <Tabs vertical>
            {regions.map((access) => {
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
        </Flex.Item>
        <Flex.Item grow={1} ml={1.5}>
          {selectedAccessEntries.map((entry) => (
            <Button.Checkbox
              fluid
              key={entry.name}
              content={entry.name}
              checked={entry.req}
              onClick={() => accessMod(entry.id)}
            />
          ))}
        </Flex.Item>
      </Flex>
    </Section>
  );
};
