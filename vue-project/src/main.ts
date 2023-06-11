import Vue from "vue";

import App from "./App.vue";
import router from "./router";

import "./assets/main.css";

import store from "./stores";

new Vue({
  router,
  store,
  render: (h) => h(App),
}).$mount("#app");
