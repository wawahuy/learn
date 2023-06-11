<template>
  <div>{{ r.out }}<button @click="test">test</button>{{ a }}</div>
</template>

<script lang="ts">
// import { mapGetters } from "vuex";
export default {
  props: ["r"],
  data() {
    return {};
  },
  computed: {
    // ...mapGetters("test", ["a"]),
    // a() {
    //   return this.$store.state.test.a;
    // }
  },
  methods: {
    test() {
      (this.r as any).out++;
      console.log(this.$route);
    },
    onInit() {
      // test
      // call api
    },
  },
  created() {
    // 1
    this.onInit();
  },
  mounted() {
    // console.log(this.$store);
    // 2
  },
};
</script>
