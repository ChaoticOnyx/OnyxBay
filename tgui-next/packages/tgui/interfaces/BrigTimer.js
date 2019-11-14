import { Fragment } from 'inferno';
import { act } from '../byond';
import { Button, Section, Box, Flex, NumberInput } from '../components';
import { createLogger } from '../logging';

const logger = createLogger('BrigTimer');

export const BrigTimer = props => {
  const { state } = props;
  const { config, data } = state;
  const { ref } = config;
  return (
    <Section
      title="Cell Timer"
      buttons={(
        <Fragment>
          <Button
            icon="clock-o"
            content={data.timing ? 'Stop' : 'Start'}
            selected={data.timing}
            onClick={() => act(ref, data.timing ? 'stop' : 'start')} />
          <Button
            icon="lightbulb-o"
            content={data.flash_charging ? 'Recharging' : 'Flash'}
            disabled={data.flash_charging}
            onClick={() => act(ref, 'flash')} />
        </Fragment>
      )}>
      <Flex direction="column" align="center">
        <Flex.Item>

          <Button
            icon="fast-backward"
            onClick={() => act(ref, 'time', { adjust: -(600 * 5) })} />
          <Button
            icon="backward"
            onClick={() => act(ref, 'time', { adjust: -600 })} />
          {' '}
          {String(Math.ceil(data.timetoset / 600))} Minutes
          {' '}
          <Button
            icon="forward"
            onClick={() => act(ref, 'time', { adjust: 600 })} />
          <Button
            icon="fast-forward"
            onClick={() => act(ref, 'time', { adjust: (600 * 5) })} />

        </Flex.Item>

        <br/>

        <Flex.Item>
          <NumberInput minValue={0} maxValue={60 * 60} unit="Minutes" value={1}
            onChange={((e, value) => act(ref, 'time', {'adjust': -data.timetoset + value * 600}))} />
        </Flex.Item>

        <br/>

        <Flex.Item>

          <Button
            icon="hourglass-start"
            content="Short"
            onClick={() => act(ref, 'time', { preset: 'short' })} />
          <Button
            icon="hourglass-start"
            content="Medium"
            onClick={() => act(ref, 'time', { preset: 'medium' })} />
          <Button
            icon="hourglass-start"
            content="Long"
            onClick={() => act(ref, 'time', { preset: 'long' })} />

        </Flex.Item>
      </Flex>
    </Section>
  );
};
