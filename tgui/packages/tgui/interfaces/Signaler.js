import { toFixed } from "../../common/math";
import { useBackend } from "../backend";
import { Button, Stack, Section, NumberInput } from "../components";
import { Window } from "../layouts";

export const Signaler = (props, context) => {
  const { act, data } = useBackend(context)
  return (
    <Window width={280} height={132}>
      <Window.Content>
        <SignalerContent />
      </Window.Content>
    </Window>
  )
}

export const SignalerContent = (props, context) => {
  const { act, data } = useBackend(context)
  const { code, frequency, maxFrequency, minFrequency } = data;
  return (
    <Section>
      <Stack vertical fill>
        <Stack.Item>
          <Stack>
            <Stack.Item color="label" width="50%">
              Frequency:
            </Stack.Item>
            <Stack.Item grow>
              <NumberInput
                animate
                width="80px"
                unit="kHz"
                step={0.2}
                stepPixelSize={6}
                minValue={minFrequency / 10}
                maxValue={maxFrequency / 10}
                value={frequency / 10}
                format={(value) => toFixed(value, 1)}
                onChange={(e, value) => act('adjust', {freq: value * 10})}
              />
            </Stack.Item>
            <Stack.Item allign="right">
              <Button
                icon="sync"
                content="Reset"
                onClick={() => act('reset', {reset: 'freq'})}
              />
            </Stack.Item>
          </Stack>
        </Stack.Item>
        <Stack.Item>
          <Stack>
            <Stack.Item color="label" width="50%">
              Code:
            </Stack.Item>
            <Stack.Item grow>
              <NumberInput
                animate
                step={1}
                stepPixelSize={6}
                minValue={1}
                maxValue={100}
                value={code}
                width="80px"
                onDrag={(e, value) => act('adjust', {code: value})}
              />
            </Stack.Item>
            <Stack.Item allign="right">
              <Button
                icon="sync"
                content="Reset"
                onClick={() => act('reset', {reset: 'code'})}
              />
            </Stack.Item>
          </Stack>
        </Stack.Item>
        <Stack.Item>
          <Stack>
            <Stack.Item width="100%">
              <Button
                fluid
                icon="arrow-up"
                content="Send Signal"
                textAlign="center"
                onClick={() => act('signal')}
              />
            </Stack.Item>
          </Stack>
        </Stack.Item>
      </Stack>
    </Section>
  )
}
