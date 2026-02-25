import { Component } from "inferno";
import { classes } from "common/react";
import { Box } from "../../../../components";
import { Slider } from "../../../../components/Slider";

export type ThermoSliderProps = {
  value: number;
  min: number;
  max: number;
  step: number;
  disabled?: boolean;
  onCommit: (v: number) => void;
};

type ThermoSliderState = { local: number | null };

const toFinite = (v: any): number | null => {
  const n = Number(v);
  return Number.isFinite(n) ? n : null;
};

const clamp = (v: number, min: number, max: number) => Math.max(min, Math.min(max, v));

/**
 * Достаёт значение из аргументов колбэка Slider/DraggableControl.
 * Поддерживает:
 * - value в диапазоне [min..max]
 * - scaledValue в диапазоне [0..1] (конвертируем в [min..max])
 * - event.target.value
 * - control-объекты с value/displayValue
 */
const pickSliderValue = (min: number, max: number, args: any[]): number | null => {
  // 1) event.target.value
  for (const a of args) {
    const tv = a?.target?.value;
    const n = toFinite(tv);
    if (n !== null) return clamp(n, min, max);
  }

  // 2) control object keys (priority: displayValue)
  for (const a of args) {
    const dv = toFinite(a?.displayValue);
    if (dv !== null) {
      // displayValue обычно уже в [min..max], но на всякий случай
      if (dv >= min && dv <= max) return dv;
      if (dv >= 0 && dv <= 1) return min + dv * (max - min);
    }
    const vv = toFinite(a?.value);
    if (vv !== null) {
      if (vv >= min && vv <= max) return vv;
      if (vv >= 0 && vv <= 1) return min + vv * (max - min);
    }
  }

  // 3) plain numbers in args
  for (const a of args) {
    const n = toFinite(a);
    if (n === null) continue;
    if (n >= min && n <= max) return n;
    if (n >= 0 && n <= 1) return min + n * (max - min);
  }

  return null;
};

export class ThermoSlider extends Component<ThermoSliderProps, ThermoSliderState> {
  state: ThermoSliderState = { local: null };

  componentDidUpdate(prevProps: ThermoSliderProps) {
    if (prevProps.value !== this.props.value && this.state.local !== null) {
      this.setState({ local: null });
    }
  }

  private shownValue() {
    const { min, max } = this.props;
    const base = this.state.local ?? this.props.value;
    return clamp(Number(base), min, max);
  }

  private handleDrag = (...args: any[]) => {
    if (this.props.disabled) return;
    const { min, max } = this.props;
    const n = pickSliderValue(min, max, args);
    if (n === null) return;
    this.setState({ local: clamp(n, min, max) });
  };

  private handleChange = (...args: any[]) => {
    if (this.props.disabled) return;
    const { min, max } = this.props;
    const n = pickSliderValue(min, max, args);
    if (n === null) return;

    const v = clamp(n, min, max);
    this.setState({ local: null });
    this.props.onCommit(v);
  };

    render() {
      const { min, max, step, disabled } = this.props;
      const shown = this.shownValue();

      const range = Math.max(0.0001, max - min);
      const pct = ((shown - min) / range) * 100;
      // ВАЖНО: минимум 1%, чтобы избежать деления на 0 в CSS
      const pctClamped = Math.max(1, Math.min(100, pct));

      const shownText = `${Math.round(shown * 10) / 10}°C`;

      return (
        <Box className={classes(["ThermoSlider", disabled && "ThermoSlider--disabled"])}>
          <Box className="ThermoSlider__row">
            <Slider
  className="ThermoSlider__control"
  value={shown}
  minValue={min}
  maxValue={max}
  step={step}
  disabled={disabled}
  onDrag={this.handleDrag as any}
  onChange={this.handleChange as any}
  stepPixelSize={10}
  suppressFlicker
  style={{ "--thermo-pct": `${pctClamped}%` } as any}
>
  {null}
</Slider>

            <Box className="ThermoSlider__miniDisplay" title="Target temperature">
              {shownText}
            </Box>
          </Box>
        </Box>
      );

    }

}

export default ThermoSlider;
