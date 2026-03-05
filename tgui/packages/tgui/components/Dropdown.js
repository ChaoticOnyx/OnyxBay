/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

import { classes } from "common/react";
import { Component, createPortal } from "inferno";
import { Box } from "./Box";
import { Icon } from "./Icon";

export class Dropdown extends Component {
  constructor(props) {
    super(props);
    this.state = {
      selected: props.selected,
      open: false,
    };
    this.menuPos = null;
    this.handleClick = () => {
      if (this.state.open) {
        this.setOpen(false);
      }
    };
    this.handleScroll = () => {
      if (this.state.open) {
        this.setOpen(false);
      }
    };
  }

  componentDidUpdate(prevProps) {
    if (prevProps.selected !== this.props.selected) {
      this.setState({ selected: this.props.selected });
    }
  }

  componentWillUnmount() {
    window.removeEventListener("click", this.handleClick);
    window.removeEventListener("scroll", this.handleScroll, true);
  }

  setOpen(open) {
    if (open) {
      const el = this.dropdownRef;
      if (el) {
        const rect = el.getBoundingClientRect();
        const spaceBelow = window.innerHeight - rect.bottom;
        const flipUp = this.props.over || spaceBelow < 200;
        this.autoOver = flipUp;
        this.menuPos = {
          left: rect.left,
          // Width of the wrapper div = same as what the menu was before
          // (position:absolute with min-width:100% of the wrapper)
          minWidth: rect.width,
          flipUp,
          top: flipUp ? undefined : rect.bottom,
          bottom: flipUp ? window.innerHeight - rect.top : undefined,
        };
      }
    } else {
      this.menuPos = null;
    }
    this.setState({ open });
    if (open) {
      setTimeout(() => {
        window.addEventListener("click", this.handleClick);
        window.addEventListener("scroll", this.handleScroll, true);
      });
    } else {
      window.removeEventListener("click", this.handleClick);
      window.removeEventListener("scroll", this.handleScroll, true);
    }
  }

  setSelected(selected) {
    this.setState({
      selected: selected,
    });
    this.setOpen(false);
    this.props.onSelected(selected);
  }

  buildMenu() {
    const { options = [] } = this.props;
    const ops = options.map((option) => (
      <Box
        key={option}
        className="Dropdown__menuentry"
        onClick={() => {
          this.setSelected(option);
        }}
      >
        {option}
      </Box>
    ));
    return ops.length ? ops : "No Options Found";
  }

  render() {
    const { props } = this;
    const {
      icon,
      iconRotation,
      iconSpin,
      color = "default",
      over,
      noscroll,
      nochevron,
      width,
      onClick,
      selected,
      disabled,
      displayText,
      // Consume fluid so it doesn't get spread onto the inner Box
      // (which would make the control block-level, bloating the measured width)
      fluid,
      ...boxProps
    } = props;
    const { className, ...rest } = boxProps;

    const pos = this.menuPos;
    const flipUp = pos ? pos.flipUp : (over || false);
    const chevronUp = this.state.open ? !flipUp : flipUp;

    // Render the open menu into document.body via a portal so it escapes
    // any overflow:hidden/auto ancestor (e.g. scrollable Section panels).
    const menu = this.state.open
      ? createPortal(
          <div
            ref={(menu) => {
              this.menuRef = menu;
            }}
            tabIndex="-1"
            style={{
              position: "fixed",
              left: pos ? pos.left : undefined,
              // Use minWidth (= wrapper width) so menu is at least as wide
              // as the control, but can grow wider for long option names.
              // Do NOT set width — the CSS min-width:100% (=100vw when fixed)
              // is neutralised here by not applying it at all via a portal.
              minWidth: pos ? pos.minWidth : undefined,
              top: pos ? pos.top : undefined,
              bottom: pos ? pos.bottom : undefined,
              zIndex: 9999,
            }}
            className={classes([
              (noscroll && "Dropdown__menu-noscroll") || "Dropdown__menu",
            ])}
          >
            {this.buildMenu()}
          </div>,
          document.body
        )
      : null;

    return (
      <div className="Dropdown" ref={(el) => { this.dropdownRef = el; }}>
        <Box
          width={width}
          className={classes([
            "Dropdown__control",
            "Button",
            "Button--color--" + color,
            disabled && "Button--disabled",
            fluid && "Button--fluid",
            className,
          ])}
          {...rest}
          onClick={() => {
            if (disabled && !this.state.open) {
              return;
            }
            this.setOpen(!this.state.open);
          }}
        >
          {icon && (
            <Icon name={icon} rotation={iconRotation} spin={iconSpin} mr={1} />
          )}
          <span className="Dropdown__selected-text">
            {displayText || this.state.selected}
          </span>
          {!!nochevron || (
            <span className="Dropdown__arrow-button">
              <Icon name={chevronUp ? "chevron-up" : "chevron-down"} />
            </span>
          )}
        </Box>
        {menu}
      </div>
    );
  }
}
