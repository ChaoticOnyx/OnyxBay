import { Icon } from '../../../components';
import { PDA_MODE } from '../programIds';
import type { PdaProgram, PdaProgramContext } from '../types';

const SupplyRecordsApp = (props: { ctx: PdaProgramContext }) => {
  const { ctx } = props;
  const supply = ctx.data?.records?.supply || {};
  const approved = supply.approved || [];
  const requests = supply.requests || [];

  return (
    <div className="PDAProgram PDAProgram--generic">
      <div className="PDAProgram__header">
        <div className="PDAProgram__title">
          <Icon name="box" /> SUPPLY RECORD INTERLINK
        </div>
      </div>

      <div className="PDAProgram__panel">
        <div className="PDAProgram__row">
          <div className="PDAProgram__k">Shuttle</div>
          <div className="PDAProgram__v">
            {supply.shuttle_moving
              ? `Moving to dock (${supply.shuttle_eta})`
              : `Shuttle at ${supply.shuttle_loc}`}
          </div>
        </div>

        <div style={{ marginTop: 12, fontWeight: 900 }}>CURRENT APPROVED ORDERS</div>
        {(approved.length && supply.approved_count) ? approved.map((order, idx) => (
          <div key={idx} style={{ marginTop: 6 }}>
            #{order.Number} - {order.Name} approved by {order.OrderedBy}
            {!!order.Comment && <div>{order.Comment}</div>}
          </div>
        )) : <div style={{ marginTop: 6 }}>No current approved orders</div>}

        <div style={{ marginTop: 12, fontWeight: 900 }}>CURRENT REQUESTED ORDERS</div>
        {(requests.length && supply.requests_count) ? requests.map((order, idx) => (
          <div key={idx} style={{ marginTop: 6 }}>
            #{order.Number} - {order.Name} requested by {order.OrderedBy}
            {!!order.Comment && <div>{order.Comment}</div>}
          </div>
        )) : <div style={{ marginTop: 6 }}>No current requested orders</div>}
      </div>
    </div>
  );
};

export const SupplyRecordsProgram: PdaProgram = {
  id: PDA_MODE.SUPPLY_RECORDS,
  title: 'Supply Records',
  icon: 'box',
  View: (ctx) => <SupplyRecordsApp ctx={ctx} />,
};
