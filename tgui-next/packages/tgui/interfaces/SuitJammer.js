import { Fragment } from 'inferno';
import { act } from '../byond';
import { Button, Section, ProgressBar, LabeledList, Toast } from '../components';

export const SuitJammer = props => {
  const { state } = props;
  const { config, data } = state;
  const { ref } = config;

  const charge = (data.current_charge / data.max_charge);
  const methods = data.methods || [];

  return (
    <Fragment>
      <Section title="Status" buttons={(
        <Button content="Toggle Jammer" icon="wifi"
          onclick={() => act(ref, (data.active ? 'disable_jammer' : 'enable_jammer'))}/>
      )}>
        <LabeledList>
          <LabeledList.Item label="State">
            {data.active ? 'Active' : 'Disabled'}
          </LabeledList.Item>
          <LabeledList.Item label="Charge">
            <ProgressBar value={String(charge)} />
          </LabeledList.Item>
        </LabeledList>
      </Section>
      <Section title="Settings">
        <LabeledList>
          <LabeledList.Item label="Range">
            {data.range}
            {' '}
            <Button disabled={data.range <= 0 ? '1' : null} icon="minus"
              onclick={() => act(ref, 'decrease_range')} />
            <Button disabled={data.range >= data.max_range ? '1' : null} icon="plus"
              onclick={() => act(ref, 'increase_range')} />
          </LabeledList.Item>
        </LabeledList>
      </Section>
      <Section title="Methods">
        {methods.map(method => {
          return (
            <Fragment>
              <Button content={method.name} disabled={data.current_method === method.ref ? '1' : null}
                onclick={() => act(ref, 'select_method', {method: method.ref})} />
              <br></br>
            </Fragment>
          );
        })}
      </Section>

      <Toast>
        Energy Consumption: ~{data.total_cost}W
      </Toast>
    </Fragment>
  );

};
