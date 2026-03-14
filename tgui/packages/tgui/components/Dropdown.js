/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

import { classes } from "common/react";
import { Component } from "inferno";
import { Box } from "./Box";
import { Icon } from "./Icon";

export class Dropdown extends Component {
  constructor(props) {
    super(props);
    this.state = {
      selected: props.selected,
    };
  }

  componentDidUpdate(prevProps) {
    if (prevProps.selected !== this.props.selected) {
      this.setState({ selected: this.props.selected });
    }
  }

  render() {
    const {
      icon,
      iconRotation,
      iconSpin,
      color = "default",
      // over / noscroll retained for API compat — unused (native select handles direction/scroll)
      over,
      noscroll,
      nochevron,
      width,
      onClick,
      selected: _selected,
      disabled,
      displayText,
      fluid,
      options = [],
      onSelected,
      ...boxProps
    } = this.props;
    const { className, ...rest } = boxProps;

    const currentSelected = this.state.selected || "";
    // "Action" dropdown: displayText is a placeholder (not a real selection).
    // After picking, the visible face reverts to displayText.
    const isAction =
      displayText !== undefined && !options.includes(currentSelected);
    // "Reselectable" mode: native select always sits at a sentinel value so
    // clicking the already-selected item still fires onChange.
    const { reselectable } = this.props;
    const usesSentinel = isAction || reselectable;

    return (
      <Box
        className={classes(["Dropdown", className])}
        width={fluid ? "100%" : width}
        {...rest}
      >
        {/* Styled visible face — pointer-events:none so clicks reach the native select */}
        <div
          className={classes([
            "Dropdown__control",
            "Button",
            "Button--color--" + color,
            disabled && "Button--disabled",
            fluid && "Button--fluid",
          ])}
        >
          {icon && (
            <Icon name={icon} rotation={iconRotation} spin={iconSpin} mr={1} />
          )}
          <span className="Dropdown__selected-text">
            {displayText || currentSelected}
          </span>
          {!nochevron && (
            <span className="Dropdown__arrow-button">
              <Icon name="chevron-down" />
            </span>
          )}
        </div>
        {/*
          Invisible native select covers the entire control area.
          The browser renders its own dropdown — no JS positioning, no clipping issues,
          no scroll hacks. Works correctly in BYOND's embedded browser.
        */}
        <select
          className="Dropdown__native"
          disabled={!!disabled}
          value={usesSentinel ? "" : currentSelected}
          onChange={(e) => {
            const val = e.target.value;
            if (!val) return;
            if (!isAction) {
              this.setState({ selected: val });
            }
            onSelected && onSelected(val);
          }}
        >
          {usesSentinel && <option value="" disabled hidden />}
          {options.map((opt) => (
            <option key={opt} value={opt}>
              {opt}
            </option>
          ))}
        </select>
      </Box>
    );
  }
}
