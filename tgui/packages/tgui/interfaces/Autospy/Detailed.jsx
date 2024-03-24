import React from 'react';

import human from './human.png';

export const DetailedInfo = () => {
  return (
    <div>
      <p>Detailed</p>
      <svg>
        <img src={human} />
        {/* Göz çizgisi */}
        <line
          x1={50}
          y1={50}
          x2={100}
          y2={100}
          tabIndex={-1}
          stroke="red"
          strokeWidth="2"
        />
        <text x={40} y={40} tabIndex={-1} textAnchor="middle">
          test
        </text>
        <line
          x1={150}
          y1={150}
          x2={200}
          y2={200}
          tabIndex={-1}
          stroke="red"
          strokeWidth="2"
        />
        <text x={140} y={140} tabIndex={-1} textAnchor="middle">
          test
        </text>
      </svg>
    </div>
  );
};
