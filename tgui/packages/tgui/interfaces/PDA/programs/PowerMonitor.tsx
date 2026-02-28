import { Icon, Button } from '../../../components';
import { PDA_MODE } from '../programIds';
import type { PdaProgram, PdaProgramContext } from '../types';

const PowerMonitorApp = (props: { ctx: PdaProgramContext }) => {
  const { ctx } = props;
  const mode = String(ctx.data?.mode || '');
  const records = ctx.data?.records || {};
  const sensors = records.power_sensors || [];
  const reading = records.sensor_reading;

  return (
    <div className="PDAProgram PDAProgram--generic">
      <div className="PDAProgram__header">
        <div className="PDAProgram__title">
          <Icon name="bolt" /> POWER MONITOR
        </div>
      </div>

      {mode === PDA_MODE.POWER_MONITOR && (
        <div className="PDAProgram__panel">
          <div className="PDAProgram__row">
            <div className="PDAProgram__k">Available Sensors</div>
            <div className="PDAProgram__v">{sensors.length}</div>
          </div>

          <div className="PDAProgram__sensorList">
            {!sensors.length && (
              <div className="PDAProgram__footerHint">No sensors found on current network.</div>
            )}
            {sensors.map((sensor, idx) => (
              <div key={`${sensor.name_tag}-${idx}`} className="PDAProgram__sensorRow">
                <Button
                  icon="plus"
                  content={sensor.name_tag}
                  fluid
                  onClick={() => ctx.act('cartridge_action', { choice: 'Power Select', target: sensor.name_tag })}
                />
              </div>
            ))}
          </div>
        </div>
      )}

      {mode === PDA_MODE.POWER_MONITOR_READING && (
        <div className="PDAProgram__panel">
          <Button icon="arrow-left" content="Back" onClick={() => ctx.act('cartridge_action', { choice: 'Power Clear' })} />

          {!reading ? (
            <div style={{ marginTop: 12 }}>Unable to contact sensor controller! Please retry.</div>
          ) : (
            <div style={{ marginTop: 10 }}>
              <div className="PDAProgram__tableWrap">
                <table className="PDATable PDAProgram__powerTable">
                  <thead>
                    <tr>
                      <th>Area</th>
                      <th style={{ textAlign: 'right' }}>Cell %</th>
                      <th style={{ textAlign: 'right' }}>Load</th>
                    </tr>
                  </thead>
                  <tbody>
                    {(reading.apc_data || []).map((row, idx) => (
                      <tr key={idx}>
                        <td className="PDAProgram__tableName">{row.name}</td>
                        <td style={{ textAlign: 'right' }}>{row.cell_charge}%</td>
                        <td style={{ textAlign: 'right' }}>{row.total_load}</td>
                      </tr>
                    ))}
                  </tbody>
                </table>
              </div>
              <div className="PDAProgram__summaryGrid" style={{ marginTop: 10 }}>
                <div>
                  <div className="PDAProgram__k">Available</div>
                  <div className="PDAProgram__v">{reading.total_avail}</div>
                </div>
                <div>
                  <div className="PDAProgram__k">Total Load</div>
                  <div className="PDAProgram__v">{reading.total_used_all}</div>
                </div>
              </div>
            </div>
          )}
        </div>
      )}
    </div>
  );
};

export const PowerMonitorProgram: PdaProgram = {
  id: PDA_MODE.POWER_MONITOR,
  title: 'Power Monitor',
  icon: 'bolt',
  View: (ctx) => <PowerMonitorApp ctx={ctx} />,
};
