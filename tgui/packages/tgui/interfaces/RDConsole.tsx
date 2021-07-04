import { useBackend, useLocalState } from '../backend';
import {
  Tabs,
  Stack,
  Section,
  LabeledList,
  Divider,
  Button,
  Table,
  Icon,
  Box,
  Tooltip,
  AnimatedNumber,
  Input,
  Flex,
} from '../components';
import { GameIcon } from '../components/GameIcon';
import { Window } from '../layouts';

const capitalize = (str: string) => {
  return str[0].toUpperCase() + str.substr(1);
};

interface InputData {
  sync: boolean;
  disk: Disk;
  techs: Tech[];
  devices: Device[];
}

interface Disk {
  type: DiskType;
  data: Tech | Design;
}

interface Device {
  name: string;
  connected: number;
  data: Data;
  busy: boolean;
}

interface Data {
  item?: Item;
  techs?: OriginTech[];
  storage?: Storage;
  filters?: string[];
  designs?: Design[];
  queue?: Design[];
}

interface Item {
  icon: string;
  name: string;
}

interface Design {
  icon: string;
  id: string;
  name: string;
  category: string;
  buildType: BuildType;
  materials: MaterialElement[];
  chemicals: ChemicalElement[];
  can_build: number;
  multipliers: { [key: string]: boolean };
}

enum BuildType {
  CircuitImprinter = 'Circuit Imprinter',
  ProtoLathe = 'Proto-lathe',
}

enum DiskType {
  Tech = 'tech',
  Design = 'design',
}

interface MaterialElement {
  name: string;
  required: number;
}

interface ChemicalElement {
  name: string;
  required: number;
}

interface Storage {
  material: StorageMaterial;
  chemical: StorageChemical;
}

interface StorageMaterial {
  total: number;
  maximum: number;
  materials: Material[];
}

interface Material {
  name: string;
  amount: number;
  icon: string;
  per_sheet: number;
}

interface StorageChemical {
  total: number;
  maximum: number;
  chemicals: Chemical[];
}

interface Chemical {
  ref: string;
  name: string;
  units: number;
}

interface OriginTech {
  name: string;
  level: number;
}

interface Tech {
  id: string;
  name: string;
  level: number;
  description: string;
}

const diskContent = (disk: Disk) => {
  const designDiskContent = (disk: Disk) => {
    const diskData: Design = disk.data as Design;

    if (!diskData) {
      return <LabeledList.Item label='Content'>Empty</LabeledList.Item>;
    }

    return (
      <LabeledList.Item label='Design'>{diskData.name}</LabeledList.Item>
    );
  };

  const techDiskContent = (disk: Disk) => {
    const diskData: Tech = disk.data as Tech;

    if (!diskData) {
      return <LabeledList.Item label='Content'>Empty</LabeledList.Item>;
    }

    return (
      <>
        <LabeledList.Item label='Technology'>{diskData.name}</LabeledList.Item>
        <LabeledList.Item label='Level'>{diskData.level}</LabeledList.Item>
        <LabeledList.Item label='Description'>
          {diskData.description}
        </LabeledList.Item>
      </>
    );
  };

  if (!disk) {
    return (
      <LabeledList>
        <LabeledList.Item label='Disk'>No Disk Inserted</LabeledList.Item>
      </LabeledList>
    );
  }

  return (
    <LabeledList>
      <LabeledList.Item label='Disk'>
        {(disk.type === DiskType.Design && 'Design Data Disk')
          || 'Technology Data Disk'}
      </LabeledList.Item>
      {(disk.type === DiskType.Design && designDiskContent(disk))
        || techDiskContent(disk)}
    </LabeledList>
  );
};

const getDeviceName = (device: Device) => {
  if (device.name === 'destructor') {
    return 'Destructive Analyzer';
  } else if (device.name === 'imprinter') {
    return 'Circuit Imprinter';
  } else if (device.name === 'protolathe') {
    return 'Protolathe';
  } else {
    throw `${device.name} is incorrect`;
  }
};

const summaryTab = (props: any, context: any) => {
  const { act, data } = useBackend<InputData>(context);

  return (
    <Stack vertical width='100%'>
      <Stack width='100%'>
        <Stack.Item width='50%'>
          <h2>Status</h2>
          <Button
            icon='sync'
            tooltipPosition='top'
            tooltip='Sync Database with Network'
            content='Sync'
            disabled={!data.sync}
            onClick={() => act('sync')}
          />
          <Button
            icon='search'
            tooltipPosition='top'
            tooltip='Re-sync with Nearby Devices'
            content='Find'
            onClick={() => act('find_device')}
          />
          {(data.sync && (
            <Button
              icon='unlink'
              tooltipPosition='top'
              tooltip='Disconnect from Fabrication Network'
              content='Disconnect'
              onClick={() => act('toggle_sync')}
            />
          )) || (
            <Button
              icon='link'
              tooltipPosition='top'
              tooltip='Connect to Fabrication Network'
              content='Connect'
              onClick={() => act('toggle_sync')}
            />
          )}
          <Button.Confirm
            color='bad'
            icon='trash'
            tooltipPosition='top'
            tooltip='Reset R&D Database'
            content='Reset'
            onClick={() => act('reset')}
          />
          <Divider />
          <LabeledList>
            {data.devices.map((device, i) => {
              return (
                <LabeledList.Item label={getDeviceName(device)}>
                  {device.connected ? 'Connected' : 'Disconnected'}
                </LabeledList.Item>
              );
            })}
          </LabeledList>
        </Stack.Item>
        <Divider vertical />
        <Stack.Item width='50%'>
          <h2>Disk Operations</h2>
          <Button
            icon='upload'
            content='Upload'
            onClick={() => act('load')}
            disabled={!data.disk?.data}
          />
          <Button
            icon='eject'
            content='Eject'
            onClick={() => act('eject')}
            disabled={!data.disk}
          />
          <Button.Confirm
            icon='eraser'
            content='Erase'
            color='bad'
            onClick={() => act('erase')}
            disabled={!data.disk?.data}
          />

          <Divider />

          {diskContent(data.disk)}
        </Stack.Item>
      </Stack>
      <Stack.Item>
        <h2>Technology Levels </h2>
        <Button
          icon='print'
          content='Print'
          onClick={() => act('print', { page: 'techs' })}
        />

        <Divider />

        {techsTable(data.techs, context)}
      </Stack.Item>
    </Stack>
  );
};

const techsTable = (techs: OriginTech[] | Tech[], context: any) => {
  const { act, data } = useBackend<InputData>(context);
  const saveButton = (tech: Tech) => {
    return data.disk?.data ? (
      <Button.Confirm
        textAlign='center'
        mt='0.2rem'
        ml='0.2rem'
        mb='0.2rem'
        width='4ch'
        icon='save'
        tooltip='Save to Disk'
        confirmContent={<Icon name='save' />}
        onClick={() => act('save', { thing: DiskType.Tech, id: tech.id })}
        disabled={!(data.disk?.type === DiskType.Tech)}
      />
    ) : (
      <Button
        textAlign='center'
        mt='0.2rem'
        ml='0.2rem'
        mb='0.2rem'
        width='4ch'
        icon='save'
        tooltip='Save to Disk'
        onClick={() => act('save', { thing: DiskType.Tech, id: tech.id })}
        disabled={!(data.disk?.type === DiskType.Tech)}
      />
    );
  };

  const techDescription = (tech: Tech) => {
    return (
      <Tooltip position='bottom' content={tech.description}>
        <Box mr='0.4rem' inline position='relative'>
          <Icon name='info' />
        </Box>
      </Tooltip>
    );
  };

  return (
    <Table className='Table--bordered'>
      <Table.Row className='candystripe'>
        <Table.Cell width='3ch' />
        <Table.Cell bold>Name</Table.Cell>
        <Table.Cell textAlign='center' bold>
          Level
        </Table.Cell>
      </Table.Row>
      {techs.length
        ? techs.map((tech: Tech, i: any) => {
            return (
              <Table.Row className='candystripe' key={i}>
                <Table.Cell>{tech.id && saveButton(tech)}</Table.Cell>
                <Table.Cell>
                  {tech.description && techDescription(tech)} {tech.name}
                </Table.Cell>
                <Table.Cell textAlign='center'>{tech.level}</Table.Cell>
              </Table.Row>
            );
          })
        : null}
    </Table>
  );
};

const destructorTab = (props: any, context: any) => {
  const { act, data } = useBackend<InputData>(context);
  const destructor = data.devices.filter((d) => d.name === 'destructor')[0];

  if (!destructor.connected) {
    return (
      <h2>
        Destructive Analyzer - Not Connected <Icon name='unlink' />
      </h2>
    );
  }

  const item = destructor.data.item;
  const capitalizedName = (item && capitalize(item.name)) || null;

  return (
    <>
      <h2>Destructive Analyzer</h2>
      <Button.Confirm
        icon='recycle'
        content='Deconstruct'
        color='bad'
        disabled={!item}
        onClick={() => act('deconstruct')}
      />
      <Button
        icon='eject'
        content='Eject'
        disabled={!item}
        onClick={() => act('eject_destructor')}
      />
      <Button
        icon='unlink'
        content='Disconnect'
        onClick={() => act('disconnect', { thing: 'destructor' })}
      />
      <Divider />
      <LabeledList>
        <LabeledList.Item label='Item'>
          {item ? capitalizedName : 'Empty'}
        </LabeledList.Item>
        <LabeledList.Item label='Technology'>
          {item && destructor.data.techs.length
            ? techsTable(destructor.data.techs, context)
            : 'Nothing'}
        </LabeledList.Item>
      </LabeledList>
    </>
  );
};

const device = (device: Device, context: any) => {
  const { act } = useBackend<InputData>(context);
  const { storage } = device.data;
  const material = storage.material;
  const chemical = storage.chemical;

  const emptyRow = () => {
    return (
      <Table.Row>
        <Table.Cell />
        <Table.Cell pl='0.5rem'>Empty</Table.Cell>
        <Table.Cell />
      </Table.Row>
    );
  };

  const ejectButtons = (material: Material) => {
    return (
      <>
        <Button.Segmented
          onClick={() =>
            act('eject_sheet', {
              from: device.name,
              thing: material.name,
              amount: 1,
            })
          }
          disabled={!material.amount}
          mt='0.2rem'
          ml='0.2rem'
          mb='0.2rem'
          content='1x'
        />
        <Button.Segmented
          onClick={() =>
            act('eject_sheet', {
              from: device.name,
              thing: material.name,
              amount: 5,
            })
          }
          disabled={!material.amount}
          mt='0.2rem'
          mb='0.2rem'
          content='5x'
        />
        <Button.Segmented
          onClick={() =>
            act('eject_sheet', {
              from: device.name,
              thing: material.name,
              amount: -1,
            })
          }
          disabled={!material.amount}
          mt='0.2rem'
          mb='0.2rem'
          content='All'
        />
      </>
    );
  };

  const disposeButtons = (chemical: Chemical) => {
    return (
      <Button
        onClick={() =>
            act('dispose', {
              from: device.name,
              thing: chemical.units,
              amount: 1,
            })
          }
        disabled={!chemical.units}
        mt='0.2rem'
        ml='0.2rem'
        mb='0.2rem'
        content='1x'
        />
    );
  };

  return (
    <Stack width='100%'>
      <Stack.Item width='33.3%'>
        <h2>
          Material Storage (
          <AnimatedNumber
            format={(value: number) => Math.round(value).toLocaleString()}
            value={material.total}
          />{' '}
          / {material.maximum.toLocaleString()})
        </h2>
        <Button
          icon='eject'
          content='Eject All'
          disabled={!material.materials.filter((mat) => mat.amount > 0).length}
          onClick={() => {
            material.materials.forEach((mat, i) => {
              mat.amount > 0
                && act('eject_sheet', {
                  from: device.name,
                  thing: mat.name,
                  amount: -1,
                });
            });
          }}
        />
        <Divider />
        <Box
          maxHeight='20rem'
          style={{
            'overflow-y': 'auto',
          }}>
          <Table className='Table--bordered'>
            <Table.Row className='candystripe'>
              <Table.Cell width='13ch' />
              <Table.Cell pl='0.8rem' bold>
                Name
              </Table.Cell>
              <Table.Cell pr='0.5rem' width='6ch' textAlign='center' bold>
                Amount
              </Table.Cell>
            </Table.Row>
            {material.materials.map((mat, i) => {
              return (
                <Table.Row className='candystripe'>
                  <Table.Cell>{ejectButtons(mat)}</Table.Cell>
                  <Table.Cell className='Materials--small'>
                    <GameIcon html={mat.icon} /> {capitalize(mat.name)}
                  </Table.Cell>
                  <Table.Cell textAlign='center'>
                    <AnimatedNumber
                      format={(value: number) =>
                        Math.round(value).toLocaleString()
                      }
                      value={mat.amount}
                    />
                  </Table.Cell>
                </Table.Row>
              );
            })}
          </Table>
        </Box>
      </Stack.Item>
      <Stack.Item width='33.3%'>
        <h2>
          Chemical Storage (
          <AnimatedNumber
            format={(value: number) => Math.round(value).toLocaleString()}
            value={chemical.total}
          />{' '}
          / {chemical.maximum.toLocaleString()})
        </h2>
        <Button.Confirm
          icon='trash'
          content='Purge All'
          color='bad'
          disabled={!chemical.chemicals.length}
          onClick={() => act('dispose', { from: device.name, thing: 'all' })}
        />
        <Divider />
        <Box
          maxHeight='20rem'
          style={{
            'overflow-y': 'auto',
          }}>
          <Table className='Table--bordered'>
            <Table.Row className='candystripe'>
              <Table.Cell width='4ch' />
              <Table.Cell pl='0.5rem' bold>
                Name
              </Table.Cell>
              <Table.Cell pr='0.5rem' width='6ch' textAlign='center' bold>
                Amount
              </Table.Cell>
            </Table.Row>
            {chemical.chemicals.length
              ? chemical.chemicals.map((chem, i) => {
                  return (
                    <Table.Row className='candystripe'>
                      <Table.Cell>
                        <Button
                          onClick={() =>
                            act('dispose', {
                              from: device.name,
                              thing: chem.ref,
                            })
                          }
                          disabled={!chem.units}
                          mt='0.2rem'
                          ml='0.2rem'
                          mb='0.2rem'
                          icon='trash'
                          color='bad'
                        />
                      </Table.Cell>
                      <Table.Cell className='Materials--small'>
                        {capitalize(chem.name)}
                      </Table.Cell>
                      <Table.Cell textAlign='center'>
                        <AnimatedNumber
                          format={(value: number) =>
                            Math.round(value).toLocaleString()
                          }
                          value={chem.units}
                        />
                      </Table.Cell>
                    </Table.Row>
                  );
                })
              : emptyRow()}
          </Table>
        </Box>
      </Stack.Item>
      <Stack.Item width='33.3%'>{queue(device, context)}</Stack.Item>
    </Stack>
  );
};

const designs = (device: Device, context: any) => {
  const { act } = useBackend<InputData>(context);
  const { designs, filters } = device.data;
  const [searchQuery, setSearchQuery] = useLocalState(
    context,
    'searchQuery',
    null,
  );

  const categories = ['All'].concat(filters);
  const [currentFilter, setFilter] = useLocalState(context, 'filter', 'All');

  let found: Design[] = designs;

  if (searchQuery !== null) {
    found = found.filter((design, _) => design.name.search(searchQuery) >= 0);
  }

  if (currentFilter !== null && currentFilter !== 'All') {
    found = found.filter((design, _) => currentFilter === design.category);
  }

  const emptyRow = () => {
    return (
      <Table.Row>
        <Table.Cell />
        <Table.Cell pl='0.5rem'>Empty</Table.Cell>
        <Table.Cell />
      </Table.Row>
    );
  };

  const buildButtons = (design: Design) => {
    const act_type = device.name === 'protolathe' ? 'build' : 'imprint';

    return (
      <>
        <Button.Segmented
          ml='0.2rem'
          content='1'
          disabled={!design.can_build}
          onClick={() => act(act_type, { id: design.id, count: 1 })}
        />
        <Button.Segmented
          content='5'
          disabled={!design.multipliers['5']}
          onClick={() => act(act_type, { id: design.id, count: 5 })}
        />
        <Button.Segmented
          content='10'
          disabled={!design.multipliers['10']}
          onClick={() => act(act_type, { id: design.id, count: 10 })}
        />
      </>
    );
  };

  return (
    <>
      <h2>Designs</h2>
      <Input
        placeholder='Search'
        fluid
        onInput={(e: any) => setSearchQuery(e.target.value)}
      />
      <Divider />
      <Flex bold wrap justify='flex-start' align='center'>
        Categories:
        {categories.map((filter, i) => {
          return (
            <Flex.Item key={i}>
              <Button.Label
                selected={filter === currentFilter}
                content={filter}
                onClick={() => {
                  act(''); // For click sound
                  setFilter(filter);
                }}
              />
            </Flex.Item>
          );
        })}
      </Flex>
      <Divider />
      <Table>
        <Table.Row className='candystripe'>
          <Table.Cell textAlign='center' bold>
            Build
          </Table.Cell>
          <Table.Cell pl='0.5rem' bold>
            Name
          </Table.Cell>
          <Table.Cell bold>Required</Table.Cell>
        </Table.Row>
        {found.length
          ? found.map((design, i) => {
              return (
                <Table.Row className='candystripe'>
                  <Table.Cell
                    style={{
                      'vertical-align': 'middle',
                    }}
                    width='11ch'>
                    {buildButtons(design)}
                  </Table.Cell>
                  <Table.Cell
                    style={{
                      'vertical-align': 'middle',
                    }}
                    className='Materials--small'>
                    <GameIcon html={design.icon} /> {design.name}
                  </Table.Cell>
                  <Table.Cell
                    style={{
                      'vertical-align': 'middle',
                      'padding-top': '0.2rem',
                      'padding-bottom': '0.2rem',
                    }}>
                    {design.materials.map((material, i) => {
                      return (
                        <Box key={i}>
                          {capitalize(material.name)
                            + ' '
                            + material.required.toLocaleString()}
                        </Box>
                      );
                    })}
                    {design.chemicals.map((chem, i) => {
                      return (
                        <Box key={i}>
                          {chem.name + ' ' + chem.required.toLocaleString()}
                        </Box>
                      );
                    })}
                  </Table.Cell>
                </Table.Row>
              );
            })
          : emptyRow()}
      </Table>
    </>
  );
};

const queue = (device: Device, context: any) => {
  const { act } = useBackend<InputData>(context);
  const { queue } = device.data;

  const emptyRow = () => {
    return (
      <Table.Row>
        <Table.Cell />
        <Table.Cell>Empty</Table.Cell>
      </Table.Row>
    );
  };

  return (
    <>
      <h2>Queue ({<AnimatedNumber value={queue.length} />})</h2>
      <Button icon='eraser' content='Clear' disabled={!queue.length} onClick={() => act('remove', { from: device.name, index: -1 })} />
      <Divider />
      <Box
        maxHeight='20rem'
        style={{
          'overflow-y': 'auto',
        }}>
        <Table className='Table--bordered'>
          <Table.Row className='candystripe'>
            <Table.Cell />
            <Table.Cell pl='0.5rem' bold>
              Name
            </Table.Cell>
          </Table.Row>
          {queue.length
            ? queue.map((design, i) => {
                return (
                  <Table.Row className='candystripe'>
                    <Table.Cell style={{ 'vertical-align': 'middle' }} width='1ch'>
                      <Button ml='0.2rem' icon='minus' onClick={() => act('remove', { from: device.name, index: i + 1 })} />
                    </Table.Cell>
                    <Table.Cell className='Materials--small'>
                      <GameIcon html={design.icon} /> {design.name}
                    </Table.Cell>
                  </Table.Row>
                );
              })
            : emptyRow()}
        </Table>
      </Box>
    </>
  );
};

const protolatheTab = (props: any, context: any) => {
  const { act, data } = useBackend<InputData>(context);
  const protolathe = data.devices.filter((d) => d.name === 'protolathe')[0];

  if (!protolathe.connected) {
    return (
      <h2>
        Protolathe - Not Connected <Icon name='unlink' />
      </h2>
    );
  }

  return (
    <>
      <h2>Protolathe</h2>
      <Button
        icon='unlink'
        content='Disconnect'
        onClick={() => act('disconnect', { thing: 'protolathe' })}
      />

      <Divider />
      {device(protolathe, context)}
      {designs(protolathe, context)}
    </>
  );
};

const imprinterTab = (props: any, context: any) => {
  const { act, data } = useBackend<InputData>(context);
  const imprinter = data.devices.filter((d) => d.name === 'imprinter')[0];

  if (!imprinter.connected) {
    return (
      <h2>
        Circuit Imprinter - Not Connected <Icon name='unlink' />
      </h2>
    );
  }

  return (
    <>
      <h2>Circuit Imprinter</h2>
      <Button
        icon='unlink'
        content='Disconnect'
        onClick={() => act('disconnect', { thing: 'imprinter' })}
      />
      <Divider />
      {device(imprinter, context)}
      {designs(imprinter, context)}
    </>
  );
};

interface Tab {
  name: string;
  icon: string;
  render: (props: any, context: any) => void;
}

const TABS: Tab[] = [
  {
    name: 'Summary',
    icon: 'info',
    render: summaryTab,
  },
  {
    name: 'Destructive Analyzer',
    icon: 'atom',
    render: destructorTab,
  },
  {
    name: 'Protolathe',
    icon: 'drafting-compass',
    render: protolatheTab,
  },
  {
    name: 'Circuit Imprinter',
    icon: 'microchip',
    render: imprinterTab,
  },
];

export const RDConsole = (props: any, context: any) => {
  const { act, data, getTheme } = useBackend<InputData>(context);
  const [selectedTab, setSelectedTab] = useLocalState(
    context,
    'selectedTab',
    TABS[0].name,
  );

  return (
    <Window
      width={1000}
      height={600}
      title='RnD Console'
      theme={getTheme('primer')}>
      <Window.Content scrollable>
        <Section>
          <Tabs fluid>
            {TABS.map((tab, i) => {
              return (
                <Tabs.Tab
                  onClick={() => {
                    act(''); // For clicking sound
                    setSelectedTab(tab.name);
                  }}
                  selected={tab.name === selectedTab}
                  icon={tab.icon}
                  key={i}>
                  {tab.name}
                </Tabs.Tab>
              );
            })}
          </Tabs>
          {TABS.filter((tab) => tab.name === selectedTab)[0].render(
            props,
            context,
          )}
        </Section>
      </Window.Content>
    </Window>
  );
};
