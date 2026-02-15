import { Component } from "inferno";
import { classes } from "common/react";
import { Box, Flex } from "../../../../components";

export type RockerState = "on" | "off";

export type RockerProps = {
  state: RockerState;
  disabled?: boolean;
  danger?: boolean;
  label: string;
  onSet: (s: RockerState) => void;
  className?: string;
};

type RockerInternalState = {
  local: RockerState | null;
  pending: RockerState | null;
  animating: boolean;
};

export class RockerSwitch extends Component<RockerProps, RockerInternalState> {
  timer: any = null;

  state: RockerInternalState = {
    local: null,
    pending: null,
    animating: false,
  };

  componentWillUnmount() {
    if (this.timer) clearTimeout(this.timer);
  }

  componentDidUpdate(prevProps: RockerProps) {
    if (prevProps.state !== this.props.state) {
      if (this.state.pending && this.props.state === this.state.pending) {
        if (this.timer) clearTimeout(this.timer);
        this.setState({ local: null, pending: null, animating: false });
        return;
      }

      if (this.state.pending && this.props.state !== this.state.pending) {
        if (this.timer) clearTimeout(this.timer);
        this.setState({ local: null, pending: null, animating: false });
        return;
      }

      if (!this.state.pending) {
        this.setState({ local: null, animating: false });
      }
    }
  }

  private getShownState(): RockerState {
    return (this.state.local ?? this.props.state) as RockerState;
  }

  private setStateOptimistic(target: RockerState) {
    if (this.props.disabled) return;

    const shown = this.getShownState();
    if (shown === target) return;

    // optimistic: фиксируем target и оставляем local, пока props не догонит
    this.setState({ local: target, pending: target, animating: true });

    if (this.timer) clearTimeout(this.timer);

    // таймер гасит только "flash", НЕ трогает local (иначе будет откат)
    this.timer = setTimeout(() => {
      this.setState({ animating: false });
    }, 140);

    this.props.onSet(target);
  }

  private onClickOn = () => this.setStateOptimistic("on");
  private onClickOff = () => this.setStateOptimistic("off");

  render() {
    const shown = this.getShownState();
    const cls = classes([
      "RockerSwitch",
      shown === "on" && "RockerSwitch--on",
      shown === "off" && "RockerSwitch--off",
      this.props.disabled && "RockerSwitch--disabled",
      this.props.danger && "RockerSwitch--danger",
      this.state.animating && "RockerSwitch--anim",
      this.props.className,
    ]);

    return (
      <Flex align="center" justify="space-between" className="RockerSwitch__row">
        <Box className="RockerSwitch__label">{this.props.label}</Box>

        <Box className={cls}>
          <Box className="RockerSwitch__rail" />
          <Box className="RockerSwitch__handle" />

          <Box className="RockerSwitch__labels RockerSwitch__labels--2">
            <Box className="RockerSwitch__lab RockerSwitch__lab--on">ON</Box>
            <Box className="RockerSwitch__lab RockerSwitch__lab--off">OFF</Box>
          </Box>

          <Box className="RockerSwitch__hit RockerSwitch__hit--2">
            <Box className="RockerSwitch__hitZone RockerSwitch__hitZone--on" onClick={this.onClickOn} />
            <Box className="RockerSwitch__hitZone RockerSwitch__hitZone--off" onClick={this.onClickOff} />
          </Box>
        </Box>
      </Flex>
    );
  }
}
