/**
 * @file
 * @copyright 2021 Aleksej Komarov
 * @license MIT
 */

import { BlockQuote, Section } from "../components";
import { BoxWithSampleText } from "./common";

export const meta = {
  title: "BlockQuote",
  // eslint-disable-next-line react/display-name
  render: () => <Story />,
};

const Story = (props, context) => {
  return (
    <Section>
      <BlockQuote>
        <BoxWithSampleText />
      </BlockQuote>
    </Section>
  );
};
