<!-- eslint-disable vue/multi-word-component-names -->
<template>
  <div>
    <TestABC :r="data" ref="refTestAbc" /><button @click="test">ABC</button>
  </div>
</template>

<script lang="ts">
import Vue from "vue";
export default Vue.extend({
  components: {
    TestABC: () => import("../../components/test/index.vue"),
  },
  data() {
    return {
      data: {
        out: 1,
      },
    };
  },
  methods: {
    test() {
      console.log(this.$refs.refTestAbc);
      this.$refs.refTestAbc.test();
    },
  },
});
</script>
