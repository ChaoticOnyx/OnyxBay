import { Fragment } from 'inferno';
import { act } from '../byond';
import { Button, Section, LabeledList, Toast, Tabs, NoticeBox, ProgressBar } from '../components';

import { createLogger } from '../logging';

const logger = createLogger('Psychoscope');

const OpenedNeuromods = props => {
  const { scan, disk } = props;

  const opened_neuromods = scan.opened_neuromods || null;
  let inserted_disk = disk;

  if (!inserted_disk) {
    inserted_disk = '';
  }

  return (
    opened_neuromods
      ? <LabeledList>
        {opened_neuromods.map(neuromod => {
          return (
            <Fragment>
              <LabeledList.Item label={neuromod.neuromod_name}>
                {neuromod.neuromod_desc}
              </LabeledList.Item>

              <LabeledList.Item label="Action">
                <Button disabled={inserted_disk === 'neuromod' ? null : '1'}
                  icon="save" content="Save to Disk"
                  onClick={() => act(ref, 'saveNeuromodToDisk', {
                    lifeform_type: scan.lifeform.type,
                    neuromod_type: neuromod.neuromod_type,
                  })}/>
              </LabeledList.Item>
              <LabeledList.Divider size={1} />
            </Fragment>
          );
        })}
      </LabeledList>
      : <NoticeBox>
            No opened neuromods.
      </NoticeBox>
  );
};

const OpenedTechnologies = props => {
  const { scan, disk } = props;

  const opened_techs = scan.opened_techs || null;

  let inserted_disk = disk;

  if (!inserted_disk) {
    inserted_disk = '';
  }

  if (scan) {
    return (
      opened_techs
        ? <LabeledList>
          {opened_techs.map(tech => {
            return (
              <Fragment>

                <LabeledList.Item label={tech.tech_name}>
                  {tech.tech_level}
                </LabeledList.Item>

                <LabeledList.Item label="Action">
                  <Button disabled={inserted_disk === 'tech' ? null : 1}
                    icon="save" content="Save to Disk"
                    onClick={() => act(ref, 'saveTechToDisk', {
                      lifeform_type: scan.lifeform.type,
                      tech_id: tech.tech_id,
                      tech_level: tech.tech_level,
                    })}/>
                </LabeledList.Item>

                <LabeledList.Divider size={1} />

              </Fragment>
            );
          })}
        </LabeledList>
        : <NoticeBox>
            No opened technologies.
        </NoticeBox>
    );
  }
  else {
    return (
      <Fragment />
    );
  }
};

const ScansJournal = props => {
  const { scans } = props;

  if (scans) {
    return (
      scans.map(scan => {
        return (
          <Section title="Scan Report">
            <LabeledList>

              <LabeledList.Item label="Date">
                {scan.date}
              </LabeledList.Item>

              <LabeledList.Item label="Object Name">
                {scan.name}
              </LabeledList.Item>

            </LabeledList>
          </Section>
        );
      })
    );
  }
  else {
    return (
      <Fragment />
    );
  }
};

export const Lifeform = props => {
  const { lifeform, scan_count } = props;

  if (lifeform) {
    return (
      <Fragment>

        <LabeledList.Item label="Kingdom">
          {lifeform.kingdom}
        </LabeledList.Item>

        <LabeledList.Item label="Class">
          {lifeform.class}
        </LabeledList.Item>

        <LabeledList.Item label="Genus">
          {lifeform.genus}
        </LabeledList.Item>

        <LabeledList.Item label="Species">
          {lifeform.species}
        </LabeledList.Item>

        <LabeledList.Item label="Description">
          {lifeform.desc}
        </LabeledList.Item>

        <LabeledList.Item label="Scans Count">
          {scan_count || lifeform.scan_count}
        </LabeledList.Item>

      </Fragment>
    );
  }
  else {
    return (
      <Fragment />
    );
  }
};

export const Psychoscope = props => {
  const { state } = props;
  const { config, data } = state;
  const { ref } = config;

  const scanned = data.scanned || null;
  const selected_lifeform = data.selected_lifeform || null;

  return (
    <Fragment>
      <Section title="Status" buttons={(
        <Fragment>
          <Button icon="lightbulb" content="Toggle Psychoscope"
            onClick={() => act(ref, 'togglePsychoscope')}/>
          {' '}
          {data.inserted_disk
            ? <Button icon="eject" content="Eject Disk"
              onClick={() => act(ref, 'ejectDisk')}/>
            : <Button icon="eject" content="Insert Disk"
              onClick={() => act(ref, 'insertDisk')}/>
          }
        </Fragment>
      )}>
        <LabeledList>
          <LabeledList.Item label="State">
            {data.status ? 'Enabled' : 'Disabled'}
          </LabeledList.Item>
          <LabeledList.Item label="Disk Slot">
            {(data.inserted_disk === 'tech' && 'Technology Disk')
            || (data.inserted_disk === 'neuromod' && 'Neuromod Disk')
            || (data.inserted_disk === 'lifeform' && 'Lifeform Disk')
            || 'Empty'
            }
          </LabeledList.Item>
          <LabeledList.Item label="Charge">
            {data.charge === null
              ? <span style="color:red;">No battery cell</span>
              : <ProgressBar value={data.charge / data.max_charge} />
            }
          </LabeledList.Item>
        </LabeledList>
      </Section>
      <Tabs>
        <Tabs.Tab label="Lifeforms List" icon="list">
          {scanned
            ? <Section title="Researched Lifeforms">
              {scanned.map(scan => {
                const lifeform = scan.lifeform;
                const button_content = (selected_lifeform && selected_lifeform.lifeform.type === lifeform.type)
                  ? lifeform.species + ' (Selected)'
                  : lifeform.species;

                return (
                  <Fragment>
                    <Button disabled={selected_lifeform && selected_lifeform.lifeform.type === lifeform.type
                      ? '1'
                      : null
                    }
                    content={button_content}
                    onClick={() => act(ref, 'showLifeform', {lifeform_type: lifeform.type})}></Button>
                    <br></br>
                  </Fragment>
                );
              })}
            </Section>
            : <NoticeBox>
                No Lifeforms!
            </NoticeBox>
          }

          <Toast>
            Opened Lifeforms: {data.opened_lifeforms + '/' + data.total_lifeforms}
          </Toast>
        </Tabs.Tab>
        <Tabs.Tab label="Lifeform Details" icon="info">
          {selected_lifeform
            ? <Fragment>
              <Section title="Lifeform Data" buttons={
                <Button disabled={data.inserted_disk === 'lifeform' ? null : '1'}
                  content="Save to Disk" icon="save"
                  onClick={() => act(ref, 'saveLifeformToDisk', {
                    lifeform_type: selected_lifeform.lifeform.type,
                  })} />
              }>
                <LabeledList>
                  <Lifeform lifeform={selected_lifeform.lifeform}
                    scan_count={data.selected_lifeform.scan_count} />
                </LabeledList>
              </Section>
              <Toast>
                {(selected_lifeform.scan_count >= selected_lifeform.lifeform.neuromod_prod_scans
                && 'You can produce the neuromods for this lifeform.')
                || 'You can not produce the neuromods for this lifeform.'
                }
              </Toast>
            </Fragment>
            : <NoticeBox>
              No Selected Lifeform.
            </NoticeBox>
          }
        </Tabs.Tab>
        <Tabs.Tab label="Discoveries" icon="microscope">
          {selected_lifeform
            ? <Fragment>
              <Section title="Opened Techonologies">
                <OpenedTechnologies scan={selected_lifeform} disk={data.inserted_disk} />
              </Section>

              <Section title="Opened Neuromods">
                <OpenedNeuromods scan={selected_lifeform} disk={data.inserted_disk} />
              </Section>
            </Fragment>
            : <NoticeBox>
              No Selected Lifeform.
            </NoticeBox>
          }
        </Tabs.Tab>
        <Tabs.Tab label="Scans Journal" icon="book">
          {selected_lifeform
            ? <ScansJournal scans={selected_lifeform.scans_journal}/>
            : <NoticeBox>
                No Selected Lifeform.
            </NoticeBox>
          }
        </Tabs.Tab>
      </Tabs>
    </Fragment>
  );
};
