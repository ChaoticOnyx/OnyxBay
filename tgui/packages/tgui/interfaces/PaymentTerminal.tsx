import { BooleanLike } from 'common/react';
import { useBackend } from '../backend';
import { Section, Box, Flex, Button, Icon } from '../components';
import { Window } from '../layouts';
import { InfernoNode } from 'inferno';

enum InputMode {
  Pin = "pin",
  Amount = "sum",
  Account = "acc"
}

interface PaymentTerminalData {
  mode: InputMode
  digits: number,
  digitsFixedLength: number,
  isRepeating: BooleanLike,
}

function getDisplayIcon(mode: InputMode): [string, string] {
  switch (mode) {
    case InputMode.Pin:
      return ["lock", "row"]
    case InputMode.Account:
      return ["hashtag", "row"]
    default:
      return ["cent-sign", "row-reverse"]
  }
}

function formatDisplayText(mode: InputMode, digits: number, count: number): string {
  let text: string
  if (count > 0) {
    text = (digits && digits.toString() || "").padEnd(count, "•")
  } else {
    text = digits.toString()
  }

  if (mode == InputMode.Pin) {
    text = text.replaceAll(/\d/g, "*");
  }

  return text
}

export const PaymentTerminal = (props: any, context: any) => {
  const { act, data } = useBackend<PaymentTerminalData>(context)
  const { mode, digits, digitsFixedLength, isRepeating } = data

  const [displayIcon, displayDirection] = getDisplayIcon(mode)
  const displayText = formatDisplayText(mode, digits, digitsFixedLength)

  return <Window width={225} height={450}>
    <Window.Content>
      <Flex p={1} direction="column" style={{ "flex-direction": "column", "gap": "1.5rem" }}>
        <Flex.Item>
          <Section>
            <Flex fillPositionedParent p="inherit" align="center" direction={displayDirection} fontSize={2}>
              <Flex.Item>
                <Icon name={displayIcon}></Icon>
              </Flex.Item>
            </Flex>
            <Box fontSize={2} textAlign="center">
              {displayText}
            </Box>
          </Section>
        </Flex.Item>
        <Flex.Item>
          <Box style={{
            gap: "1rem",
            display: "grid",
            "grid-template-columns": "repeat(6, 1fr)",
          }}>
            {Array(9).fill(0).map((_, idx) => <TerminalButton square style={{ "grid-column": "span 2" }} onClick={(_: any) => act("input_number", { value: idx + 1 })}>
              {idx + 1}
            </TerminalButton>)}
            <>
              <TerminalButton square bold color="red" textColor="darkred" style={{ "grid-column": "span 2" }} onClick={(_: any) => act("input_clear")}>
                X
              </TerminalButton>
              <TerminalButton square style={{ "grid-column": "span 2" }} onClick={(_: any) => act("input_number", { value: 0 })}>
                0
              </TerminalButton>
              <TerminalButton square bold color="green" textColor="darkgreen" style={{ "grid-column": "span 2" }} onClick={(_: any) => act("input_enter")}>
                O
              </TerminalButton>
            </>
            <>
              <TerminalButton style={{ "grid-column": "span 3", }} icon="retweet" selected={isRepeating} disabled={mode != InputMode.Amount} onClick={(_: any) => act("payment_repeat")} />
              <TerminalButton style={{ "grid-column": "span 3" }} icon="id-badge" disabled={mode != InputMode.Amount} onClick={(_: any) => act("account_reset")} />
            </>
          </Box>
        </Flex.Item>
      </Flex>
    </Window.Content>
  </Window >
}

interface TerminalButtonProps {
  [key: string]: any;
  square?: boolean;
  children?: InfernoNode;
}

const TerminalButton = (props: TerminalButtonProps) => {
  return <Box
    style={{ ...(props.style || {}) }}
  >
    <Button
      {...props}
      m={0}
      fontSize={2}
      minHeight={4}
      style={{
        display: "flex",
        "justify-content": "center",
        "align-items": "center",
        "aspect-ratio": props.square ? "1/1" : "auto",
      }}
    >
      {props.children}
    </Button>
  </Box>
}
