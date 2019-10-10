import { Fragment } from 'inferno';
import { act } from '../byond';
import { Button, Section } from '../components';
import { createLogger } from '../logging';

const logger = createLogger('BrigTimer');

export const BrigTimer = props => {
  const { state } = props;
  const { config, data } = state;
  const { ref } = config;
  return (
    <Fragment>
      <Section
        title="Cell Timer"
        buttons={(
          <Fragment>
            <Button
              icon="clock-o"
              content={data.timing ? 'Stop' : 'Start' }
              selected={data.timing}
              onClick={() => act(ref, data.timing ? 'stop' : 'start')} />
            <Button
              icon="lightbulb-o"
              content={data.flash_charging ? 'Recharging' : 'Flash' }
              disabled={data.flash_charging}
              onClick={() => act(ref, 'flash')} />
          </Fragment>
        )}>
        <Button
          icon="fast-backward"
          content="--"
          onClick={() => act(ref, 'time', { adjust: -600 })} />
        <Button
          icon="backward"
          content="-"
          onClick={() => act(ref, 'time', { adjust: -100 })} />
        {' '}
        {String(Math.ceil(data.timetoset / 10)).padStart(2, '0')}
        {' '}
        <Button
          icon="forward"
          content="+"
          onClick={() => act(ref, 'time', { adjust: 100 })} />
        <Button
          icon="fast-forward"
          content="++"
          onClick={() => act(ref, 'time', { adjust: 600 })} />
        <br />
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
      </Section>
    </Fragment>
  );
};
