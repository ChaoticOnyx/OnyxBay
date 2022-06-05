/**
 * @file
 * @copyright 2021 Aleksej Komarov
 * @license MIT
 */

import { Blink, Section } from "../components";

export const meta = {
  title: "Blink",
  // eslint-disable-next-line react/display-name
  render: () => <Story />,
};

const Story = (props, context) => {
  return (
    <Section>
      <Blink>Blink</Blink>
    </Section>
  );
};
