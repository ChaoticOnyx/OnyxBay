import { Fragment } from 'inferno';
import { act } from '../byond';
import { Box, Button, LabeledList, Section, Tabs, NoticeBox, ProgressBar, Icon } from '../components';
import { createLogger } from '../logging';
import { Lifeform } from './Psychoscope';

const logger = createLogger('NeuromodRnD');

export const BadText = props => {
  const { text, good } = props;

  return (
    <Fragment>
      <span style={good ? 'color:green;' : 'color:red;'}>{text}</span>
      {' '}
      <Icon name={good ? 'check' : 'times'}/>
    </Fragment>
  );
};

export const NeuromodRnD = props => {
  const { state } = props;
  const { config, data } = state;
  const { ref } = config;

  return (
    <Fragment>
      <Section title="Status"
        buttons={(
          <Fragment>
            {data.disk
              ? <Button icon="eject" content="Eject Disk"
                onClick={() => act(ref, 'ejectDisk')}/>
              : <Button icon="eject" content="Insert Disk"
                onClick={() => act(ref, 'insertDisk')}/>
            }

            {data.neuromod_shell
              ? <Button icon="eject" content="Eject Neuromod Shell"
                onClick={() => act(ref, 'ejectNeuromodShell')}
                disabled={data.development_progress > 0} />
              : <Button icon="eject" content="Insert Neuromod Shell"
                onClick={() => act(ref, 'insertNeuromodShell')} />
            }

            {data.beaker
              ? <Button icon="eject" content="Eject Beaker"
                onClick={() => act(ref, 'ejectBeaker')} />
              : <Button icon="eject" content="Insert Beaker"
                onClick={() => act(ref, 'insertBeaker')} />
            }
          </Fragment>
        )}>
        <LabeledList>

          <LabeledList.Item label="Neuromod Disk Slot">
            {data.disk === null
              ? 'Empty'
              : (data.disk === 'neuromod'
                ? 'Neuromod Data'
                : 'Lifeform Data'
              )
            }
          </LabeledList.Item>

          <LabeledList.Item label="Neuromod Shell Slot">
            {data.neuromod_shell
              ? (data.neuromod_shell.neuromod
                ? 'Data'
                : 'Empty Shell'
              )
              : 'Empty'
            }
          </LabeledList.Item>

          <LabeledList.Item label="Beaker Slot">
            {data.beaker
              ? 'Occuped'
              : 'Empty'
            }
          </LabeledList.Item>

          <LabeledList.Item label="Selected Lifeform">
            {data.selected_lifeform
              ? data.selected_lifeform.species
              : "No selected Lifeform"
            }
          </LabeledList.Item>

          <LabeledList.Item label="Selected Neuromod">
            {data.selected_neuromod
              ? data.selected_neuromod.name
              : "No selected Neuromod"
            }
          </LabeledList.Item>

        </LabeledList>

      </Section>
      <Tabs>
        <Tabs.Tab icon="microscope" label="Neuromod Researching">

          {data.selected_neuromod
            ? <Fragment>
              <Section title="Selected Neuromod">
                <LabeledList>

                  <LabeledList.Item label="Name">
                    {data.selected_neuromod.name}
                  </LabeledList.Item>

                  <LabeledList.Item label="Description">
                    {data.selected_neuromod.desc}
                  </LabeledList.Item>

                </LabeledList>
              </Section>

              <Section title="Researching">
                {data.selected_neuromod.researched
                  ? <NoticeBox>
                    The Neuromod is already researched.
                  </NoticeBox>
                  : <Fragment>
                    <LabeledList>

                      <LabeledList.Item label="Status">
                        {data.is_researching
                          ? 'In Progress'
                          : 'Ready'
                        }
                      </LabeledList.Item>

                      <LabeledList.Item label="Progress">
                        <ProgressBar value={String(data.research_progress / data.selected_neuromod.research_time)}/>
                      </LabeledList.Item>

                      <LabeledList.Item label="Action">
                        {data.is_researching
                          ? <Button icon="stop" content="Stop Researching"
                            onClick={() => act(ref, 'stopResearching')}
                            color="red" />
                          : <Button icon="atom" content="Start Researching"
                            onClick={() => act(ref, 'startResearching')}
                            color="green" />
                        }

                      </LabeledList.Item>
                    </LabeledList>
                  </Fragment>
                }
              </Section>
            </Fragment>
            : <NoticeBox>
                No selected neuromod.
            </NoticeBox>
          }

        </Tabs.Tab>

        <Tabs.Tab icon="industry" label="Neuromod Development">
          <Section title="Development">
            <LabeledList>

              <LabeledList.Item label="Neuromod Shell">
                {data.neuromod_shell
                  ? (data.neuromod_shell.neuromod
                    ? <Fragment>
                      <span style="color:red;">Not Empty</span>
                      {' '}
                      <Icon name="times" />
                    </Fragment>
                    : <Fragment>
                      <span style="color:green;">Ok</span>
                      {' '}
                      <Icon name="check" />
                    </Fragment>
                  )
                  : <BadText text="Empty" bad={true} />
                }
              </LabeledList.Item>

              <LabeledList.Item label="Beaker">
                {data.beaker
                  ? (data.beaker.volume < 25
                    ? <BadText text={data.beaker.volume + '/' + data.beaker.volume_max} />
                    : <BadText text={data.beaker.volume + '/' + data.beaker.volume_max} good={true} />
                  )

                  : <BadText text="Empty" />
                }
              </LabeledList.Item>

              <LabeledList.Item label="Reagents">
                {data.beaker
                  ? (data.beaker.check_status
                    ? <BadText text="Ok" good={true} />
                    : <BadText text="Bad Reagents" />
                  )
                  : <BadText text="Empty"/>
                }
              </LabeledList.Item>

              <LabeledList.Item label="Neuromod">
                {data.selected_neuromod
                  ? (data.selected_neuromod.researched
                    ? <BadText text="Researched" good={true} />
                    : <BadText text="Not Researched" />
                  )
                  : <BadText text="Not Selected" />
                }
              </LabeledList.Item>

              <LabeledList.Item label="Lifeform">
                {data.selected_lifeform
                  ? (data.selected_lifeform.scan_count >= data.selected_lifeform.neuromod_prod_scans
                    ? <BadText text="Ok" good={true} />
                    : <BadText text="Scans count not enough" />
                  )
                  : <BadText text="Not Selected" />
                }
              </LabeledList.Item>

              <LabeledList.Item label="Action">
                {data.development_progress > 0
                  ? <Button icon="stop" color="red" content="Stop Development"
                    onClick={() => act(ref, 'stopDevelopment')} />
                  : <Button icon="forward" color="green" content="Start Development"
                    onClick={() => act(ref, 'startDevelopment')}
                    disabled={data.development_ready ? null : '1'} />
                }

                {' '}

                <Button icon="trash" color="red" content="Clear Neuromod Shell"
                  onClick={() => act(ref, 'clearNeuromodShell')}
                  disabled={data.neuromod_shell && data.neuromod_shell.neuromod ? null : '1'} />
              </LabeledList.Item>

              <LabeledList.Item label="Progress">
                <ProgressBar value={String(data.development_progress / 100)} />
              </LabeledList.Item>

            </LabeledList>
          </Section>
        </Tabs.Tab>

        <Tabs.Tab icon="database" label="Data Management">
          <Section title="Data Management">
            <Tabs vertical>

              <Tabs.Tab label="Neuromods List" icon="list">
                {data.neuromods
                  ? <LabeledList>
                    {data.neuromods.map(neuromod => {
                      return (
                        <Fragment>

                          <LabeledList.Item label="Name">
                            {neuromod.name}
                          </LabeledList.Item>

                          <LabeledList.Item label="Description">
                            {neuromod.desc}
                          </LabeledList.Item>

                          <LabeledList.Item label="Researched">
                            {neuromod.researched
                              ? 'Researched'
                              : 'Not Researched'
                            }
                          </LabeledList.Item>

                          <LabeledList.Item label="Action">
                            <Button
                              content={data.selected_neuromod && data.selected_neuromod.type === neuromod.type
                                ? 'Selected'
                                : 'Select'}
                              disabled={data.selected_neuromod && data.selected_neuromod.type === neuromod.type
                                ? '1'
                                : null}
                              onClick={() => act(ref, 'selectNeuromod', {
                                neuromod_type: neuromod.type,
                              })}/>
                          </LabeledList.Item>

                          <LabeledList.Divider size={1}/>

                        </Fragment>
                      );
                    })}
                  </LabeledList>
                  : <NoticeBox>
                    No Neuromods.
                  </NoticeBox>
                }
              </Tabs.Tab>

              <Tabs.Tab label="Lifeforms List" icon="list">
                {data.lifeforms
                  ? <LabeledList>
                    {data.lifeforms.map(lifeform => {
                      return (
                        <Fragment>
                          <Lifeform lifeform={lifeform} />

                          <LabeledList.Item label="Action">
                            <Button
                              content={data.selected_lifeform && data.selected_lifeform.type === lifeform.type
                                ? 'Selected'
                                : 'Select'}
                              disabled={data.selected_lifeform && data.selected_lifeform.type === lifeform.type
                                ? '1'
                                : null}
                              onClick={() => act(ref, 'selectLifeform', {
                                lifeform_type: lifeform.type,
                              })} />
                          </LabeledList.Item>

                          <LabeledList.Divider size={2} />

                        </Fragment>
                      );
                    })}
                  </LabeledList>
                  : <NoticeBox>
                    No Lifeforms.
                  </NoticeBox>
                }
              </Tabs.Tab>

              <Tabs.Tab label="Disk Contents" icon="hdd">
                {data.disk
                  ? <LabeledList>

                    <LabeledList.Item label="Disk Type">
                      {data.disk === 'lifeform'
                        ? 'Lifeform Data'
                        : 'Neuromod Data'
                      }
                    </LabeledList.Item>

                    <LabeledList.Item label="Action">
                      <Button icon="save" content="Load from Disk"
                        onClick={() => act(ref, (
                          data.disk === 'neuromod' ? 'loadNeuromodFromDisk' : 'loadLifeformFromDisk'
                        ))}/>
                      {' '}
                      {data.disk === 'lifeform'
                        ? <Button icon="save" content="Save to Disk"
                          disabled={data.selected_lifeform ? false : true}
                          onClick={() => act(ref, 'saveLifeformToDisk', {
                            lifeform_type: data.selected_lifeform.type,
                          })} />
                        : <Button icon="save" content="Save to Disk"
                          disabled={data.selected_neuromod ? false : true}
                          onClick={() => act(ref, 'saveNeuromodToDisk', {
                            neuromod_type: data.selected_neuromod.type,
                          })} />
                      }
                    </LabeledList.Item>

                  </LabeledList>
                  : <NoticeBox>
                    No disk.
                  </NoticeBox>
                }
              </Tabs.Tab>
            </Tabs>
          </Section>
        </Tabs.Tab>
      </Tabs>
    </Fragment>
  );
};
