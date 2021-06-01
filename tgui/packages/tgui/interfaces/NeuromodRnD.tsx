import { useBackend, useLocalState } from '../backend';
import { Window } from '../layouts';
import {
  Button,
  LabeledList,
  Section,
  Tabs,
  NoticeBox,
  ProgressBar,
  Icon,
  Flex,
  Divider,
} from '../components';
import { ScanData } from './Psychoscope';

interface Beaker {
  check_status: number;
  volume_max: number;
  volume: number;
}

interface Lifeform {
  mob_type: string;
  kingdom: string;
  class: string;
  genus: string;
  species: string;
  desc: string;
  tech_rewards: any[];
  neuromod_rewards: any[];
  type: string;
  scan_count: number;
}

interface Neuromod {
  name: string;
  desc: string;
  type: string;
  chance: number;
  research_time: number;
  researched?: number;
}

interface NeuromodShell {
  neuromod: Neuromod;
  created_for: string;
}
interface InputData {
  disk: string;
  beaker: Beaker;
  neuromod_shell: NeuromodShell;
  neuromods: Neuromod[];
  lifeforms: Lifeform[];
  selected_neuromod: Neuromod;
  selected_lifeform: Lifeform;
  is_researching: number;
  research_progress: number;
  development_ready: number;
  development_progress: number;
}

const CheckItem = (props: any, _: any) => {
  const { text, checked } = props;

  return (
    <>
      <span style={checked ? 'color:green;' : 'color:red;'}>{text}</span>{' '}
      <Icon name={checked ? 'check' : 'times'} />
    </>
  );
};

const NeuromodResearching = (_: any, context: any) => {
  const { act, data } = useBackend<InputData>(context);
  const { selected_neuromod, is_researching, research_progress } = data;

  if (selected_neuromod) {
    return (
      <>
        <Section title="Neuromod">
          <LabeledList>
            <LabeledList.Item label="Name">
              {selected_neuromod.name}
            </LabeledList.Item>

            <LabeledList.Item label="Description">
              {selected_neuromod.desc}
            </LabeledList.Item>
          </LabeledList>
        </Section>
        <Section title="Researching">
          {selected_neuromod.researched ? (
            <NoticeBox>The Neuromod is already researched.</NoticeBox>
          ) : (
            <LabeledList>
              <LabeledList.Item label="Status">
                {is_researching ? 'In Progress' : 'Ready'}
              </LabeledList.Item>

              <LabeledList.Item label="Progress">
                <ProgressBar
                  value={String(
                    research_progress / selected_neuromod.research_time
                  )}
                />
              </LabeledList.Item>

              <LabeledList.Item label="Action">
                {is_researching ? (
                  <Button
                    icon="stop"
                    content="Stop Researching"
                    onClick={() => act('stopResearching')}
                    color="red"
                  />
                ) : (
                  <Button
                    icon="atom"
                    content="Start Researching"
                    onClick={() => act('startResearching')}
                    color="green"
                  />
                )}
              </LabeledList.Item>
            </LabeledList>
          )}
        </Section>
      </>
    );
  }

  return <NoticeBox>No Selected Neuromod</NoticeBox>;
};

const NeuromodDevelopment = (_: any, context: any) => {
  const { act, data } = useBackend<InputData>(context);
  const {
    neuromod_shell,
    beaker,
    selected_neuromod,
    selected_lifeform,
    development_progress,
    development_ready,
  } = data;

  return (
    <Section title="Check List">
      <LabeledList>
        <LabeledList.Item label="Neuromod Shell">
          {neuromod_shell ? (
            neuromod_shell.neuromod ? (
              <CheckItem text="Not Empty" />
            ) : (
              <CheckItem text="Ok" checked />
            )
          ) : (
            <CheckItem text="Empty" />
          )}
        </LabeledList.Item>
        <LabeledList.Item label="Beaker">
          {beaker ? (
            beaker.check_status ? (
              <CheckItem text="Ok" checked />
            ) : (
              <CheckItem text="Bad Reagents" />
            )
          ) : (
            <CheckItem text="Empty" />
          )}
        </LabeledList.Item>
        <LabeledList.Item label="Neuromod">
          {selected_neuromod ? (
            selected_neuromod.researched ? (
              <CheckItem text="Researched" checked />
            ) : (
              <CheckItem text="Not Researched" />
            )
          ) : (
            <CheckItem text="Not Selected" />
          )}
        </LabeledList.Item>
        <LabeledList.Item label="Lifeform">
          {selected_lifeform ? (
            <CheckItem text="Ok" checked />
          ) : (
            <CheckItem text="Not Selected" />
          )}
        </LabeledList.Item>
        <LabeledList.Item label="Actions">
          {development_progress > 0 ? (
            <Button
              icon="stop"
              color="red"
              content="Stop Development"
              onClick={() => act('stopDevelopment')}
            />
          ) : (
            <Button
              icon="forward"
              color="green"
              content="Start Development"
              onClick={() => act('startDevelopment')}
              disabled={development_ready ? false : true}
            />
          )}
          <Button
            icon="trash"
            color="red"
            content="Clear Neuromod Shell"
            onClick={() => act('clearNeuromodShell')}
            disabled={neuromod_shell?.neuromod ? false : true}
          />
        </LabeledList.Item>

        <LabeledList.Item label="Progress">
          <ProgressBar value={String(development_progress / 100)} />
        </LabeledList.Item>
      </LabeledList>
    </Section>
  );
};

const NeuromodsList = (_: any, context: any) => {
  const { act, data } = useBackend<InputData>(context);
  const { neuromods } = data;

  if (!neuromods) {
    return <NoticeBox ml={0.5}>No Neuromods.</NoticeBox>;
  }

  return (
    <Section ml={0.5} title="Neuromods">
      {neuromods.map((neuromod, i) => (
        <>
          <LabeledList>
            <LabeledList.Item label="Name">{neuromod.name}</LabeledList.Item>
            <LabeledList.Item label="Description">
              {neuromod.desc}
            </LabeledList.Item>
            <LabeledList.Item label="Researched">
              {neuromod.researched ? 'Researched' : 'Not Researched'}
            </LabeledList.Item>
            <LabeledList.Item label="Actions">
              <Button
                disabled={data.selected_neuromod?.type === neuromod.type}
                content="Select"
                onClick={() =>
                  act('selectNeuromod', { neuromod_type: neuromod.type })}
              />
            </LabeledList.Item>
          </LabeledList>
          {i !== neuromods.length - 1 ? <Divider /> : null}
        </>
      ))}
    </Section>
  );
};

const LifeformsList = (_: any, context: any) => {
  const { act, data } = useBackend<InputData>(context);
  const { lifeforms, selected_lifeform } = data;

  if (!lifeforms) {
    return <NoticeBox ml={0.5}>No Lifeforms.</NoticeBox>;
  }

  return (
    <Section ml={0.5} title="Lifeforms">
      {lifeforms.map((lifeform, i) => (
        <>
          <ScanData lifeformData={lifeforms[i]}>
            <Button
              disabled={selected_lifeform?.type === lifeform.type}
              content="Select"
              onClick={() =>
                act('selectLifeform', {
                  lifeform_type: lifeform.type,
                })}
            />
          </ScanData>
          {i !== lifeforms.length - 1 ? <Divider /> : null}
        </>
      ))}
    </Section>
  );
};

const DiskContents = (_: any, context: any) => {
  const { act, data } = useBackend<InputData>(context);
  const { disk } = data;

  if (!disk) {
    return <NoticeBox ml={0.5}>No Disk Found</NoticeBox>;
  }

  return (
    <Section ml={0.5} title="Disk Contents">
      <LabeledList>
        <LabeledList.Item label="Disk Type">
          {disk === 'lifeform' ? 'Lifeform Data' : 'Neuromod Data'}
        </LabeledList.Item>
        <LabeledList.Item label="Actions">
          <>
            <Button
              icon="save"
              content="Load from Disk"
              onClick={() =>
                act(
                  disk === 'neuromod'
                    ? 'loadNeuromodFromDisk'
                    : 'loadLifeformFromDisk'
              )}
            />
            {disk === 'lifeform' ? (
              <Button
                icon="save"
                content="Save to Disk"
                disabled={data.selected_lifeform ? false : true}
                onClick={() =>
                  act('saveLifeformToDisk', {
                    lifeform_type: data.selected_lifeform.type,
                  })}
              />
            ) : (
              <Button
                icon="save"
                content="Save to Disk"
                disabled={data.selected_neuromod ? false : true}
                onClick={() =>
                  act('saveNeuromodToDisk', {
                    neuromod_type: data.selected_neuromod.type,
                  })}
              />
            )}
          </>
        </LabeledList.Item>
      </LabeledList>
    </Section>
  );
};

const DataManagement = (props: any, context: any) => {
  const [tabIndex, setTabIndex] = useLocalState(context, 'tabDataIndex', 0);

  const tabs = [
    {
      label: 'Neuromods List',
      icon: 'list',
      getContent: NeuromodsList,
    },
    {
      label: 'Lifeforms List',
      icon: 'list',
      getContent: LifeformsList,
    },
    {
      label: 'Disk Contents',
      icon: 'hdd',
      getContent: DiskContents,
    },
  ];

  return (
    <Flex>
      <Flex.Item>
        <Tabs vertical>
          {tabs.map((tab, i) => (
            <Tabs.Tab
              key={i}
              icon={tab.icon}
              selected={i === tabIndex}
              onClick={() => setTabIndex(i)}>
              {tab.label}
            </Tabs.Tab>
          ))}
        </Tabs>
      </Flex.Item>
      <Flex.Item grow>{tabs[tabIndex].getContent(props, context)}</Flex.Item>
    </Flex>
  );
};

export const NeuromodRnD = (props: any, context: any) => {
  const { act, data } = useBackend<InputData>(context);
  const [tabIndex, setTabIndex] = useLocalState(context, 'tabIndex', 0);

  const tabs = [
    {
      label: 'Neuromod Researching',
      icon: 'microscope',
      getContent: NeuromodResearching,
    },
    {
      label: 'Neuromod Development',
      icon: 'industry',
      getContent: NeuromodDevelopment,
    },
    {
      label: 'Data Management',
      icon: 'database',
      getContent: DataManagement,
    },
  ];

  return (
    <Window width={520} height={600}>
      <Window.Content fitted>
        <Section
          title="Status"
          buttons={
            <>
              {data.disk ? (
                <Button
                  icon="eject"
                  content="Eject Disk"
                  onClick={() => act('ejectDisk')}
                />
              ) : (
                <Button
                  icon="eject"
                  content="Insert Disk"
                  onClick={() => act('insertDisk')}
                />
              )}

              {data.neuromod_shell ? (
                <Button
                  icon="eject"
                  content="Eject Neuromod Shell"
                  onClick={() => act('ejectNeuromodShell')}
                  disabled={data.development_progress > 0}
                />
              ) : (
                <Button
                  icon="eject"
                  content="Insert Neuromod Shell"
                  onClick={() => act('insertNeuromodShell')}
                />
              )}

              {data.beaker ? (
                <Button
                  icon="eject"
                  content="Eject Beaker"
                  onClick={() => act('ejectBeaker')}
                />
              ) : (
                <Button
                  icon="eject"
                  content="Insert Beaker"
                  onClick={() => act('insertBeaker')}
                />
              )}
            </>
          }>
          <LabeledList>
            <LabeledList.Item label="Neuromod Disk Slot">
              {data.disk === null
                ? 'Empty'
                : data.disk === 'neuromod'
                ? 'Neuromod Data'
                : 'Lifeform Data'}
            </LabeledList.Item>

            <LabeledList.Item label="Neuromod Shell Slot">
              {data.neuromod_shell
                ? data.neuromod_shell.neuromod
                  ? 'Data'
                  : 'Empty Shell'
                : 'Empty'}
            </LabeledList.Item>

            <LabeledList.Item label="Beaker Slot">
              {data.beaker ? 'Occuped' : 'Empty'}
            </LabeledList.Item>

            <LabeledList.Item label="Selected Lifeform">
              {data.selected_lifeform
                ? data.selected_lifeform.species
                : 'No selected Lifeform'}
            </LabeledList.Item>

            <LabeledList.Item label="Selected Neuromod">
              {data.selected_neuromod
                ? data.selected_neuromod.name
                : 'No selected Neuromod'}
            </LabeledList.Item>
          </LabeledList>
        </Section>
        <Tabs fluid>
          {tabs.map((tab, i) => (
            <Tabs.Tab
              key={i}
              icon={tab.icon}
              selected={i === tabIndex}
              onClick={() => setTabIndex(i)}>
              {tab.label}
            </Tabs.Tab>
          ))}
        </Tabs>
        {tabs[tabIndex].getContent(props, context)}
      </Window.Content>
    </Window>
  );
};
