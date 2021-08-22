import { useBackend, useLocalState } from '../backend';
import { AnimatedNumber, Box, Button, Icon, LabeledList, ProgressBar, Section } from '../components';
import { Window } from '../layouts';

interface BeakerContent
{
  name: string;
  volume: any;
}
interface DispenserInput
{
  beakerTransferAmounts: number[];
  isBeakerLoaded: any;
  beakerContents: BeakerContent[];
  amount: number;
  chemicals: string[];
  beakerCurrentVolume: number;
  beakerMaxVolume: number;
}

export const Dispenser = (props, context) => {
  const { act, data } = useBackend<DispenserInput>(context);
  const beakerTransferAmounts = data.beakerTransferAmounts;
  const beakerContents = data.beakerContents || [];
  return (
    <Window
      width={565}
      height={620}>
      <Window.Content scrollable>
        <Section
          title='Dispense'
          buttons={(
            beakerTransferAmounts.map(amount => (
              <Button
                key={amount}
                icon='plus'
                selected={Math.round(amount) === Math.round(data.amount)}
                content={amount}
                onClick={() => act('amount', {
                  target: amount,
                })} />
            ))
          )}>
          <Box mr={-1}>
            {data.chemicals.map(chemical => (
              <Button
                content={chemical}
                key={chemical}
                title={chemical}
                icon='tint'
                width='129.5px'
                lineHeight={1.75}
                onClick={() => act('dispense', {
                  reagent: chemical,
                })} />
            ))}
          </Box>
        </Section>
        <Section
          title='Beaker'>
          <LabeledList>
            <LabeledList.Item
              label='Beaker'
              buttons={data.isBeakerLoaded && (
                <Button
                  icon='eject'
                  content='Eject'
                  disabled={!data.isBeakerLoaded}
                  onClick={() => act('eject')} />
              )}>
              {data.isBeakerLoaded
                  && (
                    <>
                      <AnimatedNumber
                        initial={0}
                        value={data.beakerCurrentVolume} />
                      /{data.beakerMaxVolume} units
                    </>
                  )
                || 'No beaker'}
            </LabeledList.Item>
            <LabeledList.Item
              label='Contents'>
              <Box color='label'>
                {(!data.isBeakerLoaded) && 'N/A'
                  || beakerContents.length === 0 && 'Nothing'}
              </Box>
              {beakerContents.map(chemical => (
                <Box
                  key={chemical.name}
                  color='label'>
                  <AnimatedNumber
                    initial={0}
                    value={chemical.volume} />
                  {' '}
                  units of {chemical.name}
                </Box>
              ))}
            </LabeledList.Item>
          </LabeledList>
        </Section>
      </Window.Content>
    </Window>
  );
};
