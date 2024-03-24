import React, { useEffect, useRef } from 'react';

import { backendSuspendStart, globalStore } from '../../backend';
import { dragStartHandler, recallWindowGeometry } from '../../drag';
import { DetailedInfo } from './Detailed';
import pc from './healthui.png';

const DEFAULT_SIZE = [800, 522];

export const Autospy = (props) => {
  const dispatch = globalStore.dispatch;
  const dragAreaRef = useRef(null);

  const handleMouseDown = (e) => {
    if (e.target === dragAreaRef.current) {
      dragStartHandler(e);
    }
  };

  const { canClose = true, width, height } = props;

  const handleClose = () => {
    dispatch(backendSuspendStart());
  };
  useEffect(() => {
    const updateGeometry = () => {
      const options = {
        size: DEFAULT_SIZE,
      };

      if (width && height) {
        options.size = [width, height];
      }
      recallWindowGeometry(options);
    };

    Byond.winset(Byond.windowId, {
      'can-close': Boolean(canClose),
    });
    updateGeometry();
  }, [width, height]);
  return (
    <div
      ref={dragAreaRef}
      onMouseDown={(e) => handleMouseDown(e)}
      style={{
        position: 'relative',
        width: '800px',
        height: '522px',
        backgroundImage: `url(${pc})`,
        opacity: 1,
        backgroundSize: 'cover',
      }}
    >
      {/* Inner divs */}
      <div
        style={{
          position: 'absolute',
          top: '49px',
          left: '94px',
          width: '656px',
          height: '381px',
          background: '#c8cfd7',
        }}
      >
        <DetailedInfo />
      </div>

      {/* Close button */}
      <div
        style={{
          position: 'absolute',
          top: '0',
          right: '0',
          cursor: 'pointer',
          padding: '10px',
          paddingLeft: '20px',
        }}
        onClick={handleClose}
      >
        ×
      </div>
    </div>
  );
};
