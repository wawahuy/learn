interface State {
  a: number;
}

const initState: State = {
  a: 1,
};

const state = { ...initState };

const getters = {
  a: (state: State) => state.a,
};

const mutations = {
  ["TEST"]: (state: any) => {
    state.a++;
  },
};

export default {
  state,
  getters,
  mutations,
  namespace: true,
}
