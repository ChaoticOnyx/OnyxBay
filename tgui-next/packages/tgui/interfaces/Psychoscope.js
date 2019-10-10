import { Fragment } from 'inferno';
import { act } from '../byond';
import { Button, Section, Box, LabeledList, Toast, Tabs, NoticeBox, Flex } from '../components';

import { createLogger } from '../logging';

const logger = createLogger('Psychoscope')

const OpenedNeuromods = props => {
  const { scan, disk } = props;

  const opened_neuromods = scan.opened_neuromods || [];
  var inserted_disk = disk;

  if (!inserted_disk) {
    inserted_disk = '';
  };

  if (opened_neuromods) {
    return (
      <Fragment>
        {opened_neuromods.length ?
          <Fragment>
            <LabeledList>
              {opened_neuromods.map(neuromod => {
                return (
                  <Fragment>
                    <br></br>
                    <LabeledList.Item label={neuromod.neuromod_name}>
                      {neuromod.neuromod_desc}
                    </LabeledList.Item>

                    <LabeledList.Item label='Action'>
                      <Button disabled={inserted_disk == 'neuromod' ? null : '1'}
                        icon='save' content='Save to Disk'
                        onclick={() => act(ref, 'saveNeuromodToDisk', {
                          lifeform_type: scan.lifeform.type,
                          neuromod_type: neuromod.neuromod_type,
                      })}/>
                    </LabeledList.Item>
                  </Fragment>
                );
              })}
            </LabeledList>
          </Fragment>
          :
          <NoticeBox>
            No opened neuromods.
          </NoticeBox>
        }
      </Fragment>
    );
  } else {
    return (
      <Fragment>

      </Fragment>
    );
  }
};

const OpenedTechnologies = props => {
  const { scan, disk } = props;

  const opened_techs = scan.opened_techs || [];

  var inserted_disk = disk;

  if (!inserted_disk) {
    inserted_disk = '';
  };

  if (scan) {
    return (
      <Fragment>
        {opened_techs.length ?
          <Fragment>
            <LabeledList>
              {opened_techs.map(tech => {
                return (
                <Fragment>
                  <br></br>
                  <LabeledList.Item label={tech.tech_name}>
                        {tech.tech_level}
                  </LabeledList.Item>

                  <LabeledList.Item label='Action'>
                    <Button disabled={inserted_disk == 'tech' ? null : 1}
                      icon='save' content='Save to Disk'
                      onclick={() => act(ref, 'saveTechToDisk', {
                        lifeform_type: scan.lifeform.type,
                        tech_id: tech.tech_id,
                        tech_level: tech.tech_level,
                    })}/>
                  </LabeledList.Item>
                </Fragment>
              );})}
            </LabeledList>
          </Fragment>
          :
          <Fragment>
            <NoticeBox>
              No opened technologies.
            </NoticeBox>
          </Fragment>
        }
      </Fragment>
    );
  } else {
    return (
      <Fragment>

      </Fragment>
    );
  }
};

const ScansJournal = props => {
  const { scans } = props;

  if (scans) {
    return (
      <Fragment>
        {scans.map(scan => {
          return (
            <Fragment>
              <Section title='Scan Report'>
              <LabeledList>
                <LabeledList.Item label='Date'>
                  {scan.date}
                </LabeledList.Item>
                <LabeledList.Item label='Object Name'>
                  {scan.name}
                </LabeledList.Item>
              </LabeledList>
              </Section>
            </Fragment>
          );
        })}
      </Fragment>
    );
  } else {
    return (
      <Fragment>
      </Fragment>
    );
  }
};

const Lifeform = props => {
  const { lifeform, scan_count } = props;

  if (lifeform) {
    return (
      <Fragment>

        <LabeledList>
          <LabeledList.Item label='Kingdom'>
            {lifeform.kingdom}
          </LabeledList.Item>
          <LabeledList.Item label='Class'>
            {lifeform.class}
          </LabeledList.Item>
          <LabeledList.Item label='Genus'>
            {lifeform.genus}
          </LabeledList.Item>
          <LabeledList.Item label='Species'>
            {lifeform.species}
          </LabeledList.Item>
          <LabeledList.Item label='Description'>
            {lifeform.desc}
          </LabeledList.Item>
          <LabeledList.Item label='Scans Count'>
            {scan_count ? scan_count : 0}
          </LabeledList.Item>
        </LabeledList>

      </Fragment>
    );
  } else {
    return (
    <Fragment>

    </Fragment>
    );
  }
};

export const Psychoscope = props => {
  const { state } = props;
  const { config, data } = state;
  const { ref } = config;

  const scanned = data.scanned || [];
  const selected_lifeform = data.selected_lifeform || [];

  return (
    <Fragment>
      <Section title='Status' buttons={(
        <Fragment>
          <Button icon='lightbulb' content='Toggle Psychoscope'
            onclick={() => act(ref, 'togglePsychoscope')}/>
          {' '}
          {data.inserted_disk ?
            <Button icon='eject' content='Eject Disk'
              onclick={() => act(ref, 'ejectDisk')}/> :
            <Button icon='eject' content='Insert Disk'
              onclick={() => act(ref, 'insertDisk')}/>
          }
        </Fragment>
      )}>
        <LabeledList>
          <LabeledList.Item label='State'>
            {data.status ? 'Enabled' : 'Disabled'}
          </LabeledList.Item>
          <LabeledList.Item label='Disk Slot'>
            {(data.inserted_disk == 'tech' && 'Technology Disk') ||
            (data.inserted_disk == 'neuromod' && 'Neuromod Disk') ||
            (data.inserted_disk == 'lifeform' && 'Lifeform Disk') ||
            'Empty'
            }
          </LabeledList.Item>
        </LabeledList>
      </Section>
      <Tabs>
        <Tabs.Tab label='Lifeforms List' icon='list'>
            {(scanned.length == 0 &&
              <Fragment>
                <NoticeBox>
                  No Lifeforms!
                </NoticeBox>
              </Fragment>
            ) ||
              <Section title='Researched Lifeforms'>
                {scanned.map(scan => {
                  const lifeform = scan.content.lifeform

                  return (
                    <Fragment>
                      <Button content={lifeform.species}
                        onclick={() => act(ref, 'showLifeform', {lifeform_type: scan.lifeform_type})}></Button>
                        <br></br>
                    </Fragment>
                  );
                })}
              </Section>
            }

          <Toast>
            Opened Lifeforms: {data.opened_lifeforms + '/' + data.total_lifeforms}
          </Toast>
        </Tabs.Tab>
        <Tabs.Tab label='Lifeform Details' icon='info'>
          {selected_lifeform ?
            <Fragment>
              <Section title='Lifeform Data' buttons={
                <Button disabled={data.inserted_disk == 'lifeform' ? null : '1'}
                  content='Save to Disk' icon='save'
                  onclick={() => act(ref, 'saveLifeformToDisk', {
                    lifeform_type: selected_lifeform.lifeform_type
                  })} />
              }>
                <Lifeform lifeform={selected_lifeform.content.lifeform} scan_count={data.selected_lifeform.content.scan_count} />
              </Section>
              <Toast>
                {(selected_lifeform.content.scan_count >= selected_lifeform.content.lifeform.neuromod_prod_scans && 'You can produce the neuromods for this lifeform.') ||
                'You can not produce the neuromods for this lifeform.'
                }
              </Toast>
            </Fragment>
            :
            <NoticeBox>
              No Selected Lifeform.
            </NoticeBox>
          }
        </Tabs.Tab>
        <Tabs.Tab label='Discoveries' icon='microscope'>
          {selected_lifeform ?
            <Fragment>
              <Section title='Opened Techonologies'>
                <OpenedTechnologies scan={selected_lifeform.content} disk={data.inserted_disk} />
              </Section>

              <Section title='Opened Neuromods'>
                <OpenedNeuromods scan={selected_lifeform.content} disk={data.inserted_disk} />
              </Section>
            </Fragment>
            :
            <NoticeBox>
              No Selected Lifeform.
            </NoticeBox>
          }
        </Tabs.Tab>
        <Tabs.Tab label='Scans Journal' icon='book'>
          {selected_lifeform ?
            <Fragment>
              <ScansJournal scans={selected_lifeform.content.scans_journal}/>
            </Fragment>
            :
            <NoticeBox>
              No Selected Lifeform.
            </NoticeBox>
          }
        </Tabs.Tab>
      </Tabs>
    </Fragment>
  )}
