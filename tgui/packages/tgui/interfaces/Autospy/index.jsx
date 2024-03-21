import React from 'react';

import { dragStartHandler } from '../../drag';
import pc from './doll.png';
export const Autospy = () => {
  return (
    <div>
      <div
        className="dragArea"
        style={{ background: 'red' }}
        onMouseDown={(e) => dragStartHandler(e)}
      >
        <img src={pc} alt="pc" />
        <p>autospy test</p>
      </div>
    </div>
  );
};
