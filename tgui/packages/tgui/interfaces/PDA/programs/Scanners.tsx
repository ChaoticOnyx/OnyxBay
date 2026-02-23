import { Component } from 'inferno';
import { Icon, Button } from '../../../components';
import type { PdaProgram, PdaProgramContext } from '../types';

class ToggleToolApp extends Component<{
  title: string;
  icon: string;
  onLabel: string;
  offLabel: string;
}> {
  private enabled = false;
  private last: string | null = null;

  private toggle = () => {
    this.enabled = !this.enabled;
    this.last = this.enabled ? 'Enabled.' : 'Disabled.';
    this.forceUpdate();
  };

  render() {
    const { title, icon, onLabel, offLabel } = this.props;

    return (
      <div className="PDAProgram PDAProgram--generic">
        <div className="PDAProgram__header">
          <div className="PDAProgram__title">
            <Icon name={icon} /> {title.toUpperCase()}
          </div>
          <div className="PDAProgram__sub">UI-only mock • Cartridge toggle</div>
        </div>

        <div className="PDAProgram__panel">
          <div className="PDAProgram__row">
            <div className="PDAProgram__k">State</div>
            <div className="PDAProgram__v">{this.enabled ? 'ON' : 'OFF'}</div>
          </div>

          <div style={{ marginTop: 10 }}>
            <Button
              icon="power-off"
              content={this.enabled ? offLabel : onLabel}
              onClick={this.toggle}
            />
          </div>

          {this.last && (
            <div className="PDAProgram__footerHint" style={{ marginTop: 10, opacity: 0.8 }}>
              {this.last}
            </div>
          )}
        </div>
      </div>
    );
  }
}

export const ReagentScannerProgram: PdaProgram = {
  id: 'reagent_scanner',
  title: 'Reagent Scanner',
  icon: 'flask',
  canRun: (ctx) => ctx.cartridgeType === 'admin' || ctx.cartridgeType === 'medical',
  View: () => (
    <ToggleToolApp
      title="Reagent Scanner"
      icon="flask"
      onLabel="Enable Reagent Scanner"
      offLabel="Disable Reagent Scanner"
    />
  ),
};

export const HalogenCounterProgram: PdaProgram = {
  id: 'halogen_counter',
  title: 'Halogen Counter',
  icon: 'radiation',
  canRun: (ctx) => ctx.cartridgeType === 'engineering',
  View: () => (
    <ToggleToolApp
      title="Halogen Counter"
      icon="radiation"
      onLabel="Enable Halogen Counter"
      offLabel="Disable Halogen Counter"
    />
  ),
};

export const GasScannerProgram: PdaProgram = {
  id: 'gas_scanner',
  title: 'Gas Scanner',
  icon: 'smog',
  canRun: (ctx) => ctx.cartridgeType === 'admin' || ctx.cartridgeType === 'engineering',
  View: () => (
    <ToggleToolApp
      title="Gas Scanner"
      icon="smog"
      onLabel="Enable Gas Scanner"
      offLabel="Disable Gas Scanner"
    />
  ),
};
