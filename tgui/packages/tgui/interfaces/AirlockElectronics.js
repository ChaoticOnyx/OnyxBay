import { useBackend, useLocalState } from '../backend';
import { Button, Flex, LabeledList, Section, Tabs } from '../components';
import { Window } from '../layouts';
import { sortBy } from 'common/collections';

export const AirlockElectronics = (props, context) => {
  const { act, data } = useBackend(context);
  const { oneAccess, unres_direction } = data;
  const regions = data.regions || [];
  let accesses = [];
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
                icon={oneAccess ? 'unlock' : 'lock'}
                content={oneAccess ? 'One' : 'All'}
                onClick={() => act('one_access')}
              />
            </LabeledList.Item>
          </LabeledList>
        </Section>
        <AirlockAccessList
          accesses={regions}
          selectedList={accesses}
          accessMod={(id) =>
            act('set', {
              access: id,
            })}
        />
      </Window.Content>
    </Window>
  );
};

const diffMap = {
  0: {
    icon: 'times-circle',
    color: 'bad',
  },
  1: {
    icon: 'stop-circle',
    color: null,
  },
  2: {
    icon: 'check-circle',
    color: 'good',
  },
};

export const AirlockAccessList = (props, context) => {
  const { accesses = [], selectedList = [], accessMod } = props;
  const [selectedAccessName, setSelectedAccessName] = useLocalState(
    context,
    'accessName',
    accesses[0]?.name
  );
  const selectedAccess = accesses.find(
    (access) => access.name === selectedAccessName
  );
  const selectedAccessEntries = sortBy((entry) => entry.desc)(
    selectedAccess?.accesses || []
  );

  const checkAccessIcon = (accesses) => {
    let oneAccess = false;
    let oneInaccess = false;
    for (let element of accesses) {
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
            {accesses.map((access) => {
              const entries = access.accesses || [];
              const icon = diffMap[checkAccessIcon(entries)].icon;
              const color = diffMap[checkAccessIcon(entries)].color;
              return (
                <Tabs.Tab
                  key={access.name}
                  altSelection
                  color={color}
                  icon={icon}
                  selected={access.name === selectedAccessName}
                  onClick={() => setSelectedAccessName(access.name)}>
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
