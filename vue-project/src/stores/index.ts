import Vue from "vue";
import VueX from "vuex";
import test from "./test";

Vue.use(VueX);

const store = new VueX.Store({
  modules: {
    test,
  },
});

export default store;
