import { useBackend } from "../backend";
import { Button, Section, Flex, NoticeBox, Box } from "../components";
import { Window } from "../layouts";

export const Teleporter = (props, context) => {
  const { act, data } = useBackend(context)
  return (
    <Window width={340} height={140}>
      <Window.Content>
        <UiData />
      </Window.Content>
    </Window>
  )
}

const UiData = (props, context) => {
  const { act, data } = useBackend(context)
  const { gate, target, mode, engaged, panel} = data

  if(!gate)
    return <NoticeBox>Error: No Gate connected.</NoticeBox>

  return (
    <Section
      title="Gate Controls: "
      fill
      buttons={
        <>
        <Button
        content={mode}
        onClick={() => act("modeset")}
        />
        <Button
        icon="wrench"
        selected={panel}
        onClick={() => act("togglemaint")}
        />
        <Button
        icon="power-off"
        selected={engaged}
        onClick={() => act("toggle")}
        />
        </>
      }
    >
      <Flex height="100%" direction="column" justify="space-around">
        <Flex.Item>
          <Flex direction="row" justify="space-between">
            <Flex.Item>
              Target:
            </Flex.Item>
            <Flex.Item>
              <Button
              icon="edit"
              content={target}
              onClick={() => {act("targetset")}}
              />
            </Flex.Item>
          </Flex>
        </Flex.Item>
      </Flex>
    </Section>
  )
}
