/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

const initialState = {
  visible: false,
  playing: false,
  track: null,
  jukebox: {},
};

export const audioReducer = (state = initialState, action) => {
  const { type, payload } = action;
  if (type === 'audio/playing') {
    return {
      ...state,
      visible: true,
      playing: true,
    };
  }
  if (type === 'audio/stopped') {
    const visible = Object.values(state.jukebox).filter((s) => !!s).length > 0;

    return {
      ...state,
      visible,
      playing: false,
    };
  }
  if (type === 'audio/playMusic') {
    return {
      ...state,
      meta: payload,
    };
  }
  if (type === 'audio/stopMusic') {
    return {
      ...state,
      visible: false,
      playing: false,
      meta: null,
    };
  }
  if (type === 'audio/toggle') {
    return {
      ...state,
      visible: !state.visible,
    };
  }
  if (type === 'audio/jukebox/playing') {
    return {
      ...state,
      visible: true,
    };
  }
  if (type === 'audio/jukebox/stopped') {
    let visible = !!state.meta;
    if (!visible) {
      for (const key of Object.keys(state.jukebox).filter(
        (k) => k !== payload.jukeboxId
      )) {
        if (state.jukebox[key]) {
          visible = true;
          break;
        }
      }
    }

    return {
      ...state,
      visible,
      jukebox: {
        ...state.jukebox,
        [payload.jukeboxId]: null,
      },
    };
  }
  if (type === 'audio/jukebox/create') {
    return {
      ...state,
      jukebox: {
        ...state.jukebox,
        [payload.jukeboxId]: null,
      },
    };
  }
  if (type === 'audio/jukebox/destroy') {
    const jukebox = { ...state.jukebox };
    delete jukebox[payload.jukeboxId];

    return {
      ...state,
      jukebox,
    };
  }
  if (type === 'audio/jukebox/playMusic') {
    return {
      ...state,
      jukebox: {
        ...state.jukebox,
        [payload.jukeboxId]: payload,
      },
    };
  }
  return state;
};
