import Vue from 'vue'
import FeedBack from '../../components/feed_back/FeedBack.vue'

Vue.component('feed-back-vue', FeedBack)

new Vue({
  el: '#feed-back',
  render: h => h(FeedBack)
});
