import { Fragment } from 'inferno';
import { act } from '../byond';
import { Button, LabeledList, Section, ProgressBar } from '../components';

export const Resleever = props => {
  const { state } = props;
  const { config, data } = state;
  const { ref } = config;

  const progress = String(data.remaining / data.timetosleeve);

  return (
    <Fragment>
      <Section title="Content"
        buttons={(
          <Fragment>
            <Button icon="eject" content="Eject Occupant" disabled={data.isOccupiedEjectable ? null : '1'}
              onclick={() => act(ref, 'eject')} />
            {' '}
            <Button icon="eject" content="Eject Lace" disabled={data.isLaceEjectable ? null : '1'}
              onclick={() => act(ref, 'ejectlace')}/>
          </Fragment>
        )}>
        <LabeledList>
          <LabeledList.Item label="Occupant">
            {data.name ? data.name : 'Empty'}

          </LabeledList.Item>
          <LabeledList.Item label="Backup">
            {data.lace ? data.lace : 'Empty'}

          </LabeledList.Item>
        </LabeledList>
      </Section>

      <Section title="Procedure"
        buttons={(
          <Fragment>
            <Button icon="play" content="Start Procedure" disabled={data.ready ? null : '0'}
              onclick={() => act(ref, 'begin')}/>
          </Fragment>
        )}>
        <LabeledList>
          <LabeledList.Item label="Status">
            {(progress > 0 && 'In Progress')
              || (data.ready ? 'Ready' : 'Not Ready')}
          </LabeledList.Item>
          <LabeledList.Item label="Progress">
            <ProgressBar value={progress} />
          </LabeledList.Item>
        </LabeledList>
      </Section>
    </Fragment>
  );
};
