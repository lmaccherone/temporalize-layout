// Generated by CoffeeScript 1.9.2
Polymer({
  is: "x-app",
  ready: function() {
    this.gestureActive = true;
    this.step = 0;
    this.steps = [
      {
        index: 0
      }, {
        index: 1
      }, {
        index: 2
      }
    ];
    return console.log(document.querySelector('burn-Chart').step);
  },
  properties: {
    _isMobile: {
      type: Boolean,
      observer: "_isMobileChanged"
    },
    step: Number
  },
  _listTap: function() {
    return this.$.drawerPanel.closeDrawer();
  },
  _isMobileChanged: function(isMobile) {
    this.mainMode = (isMobile ? "seamed" : "cover");
    this.drawerWidth = (isMobile ? "100%" : "50px");
    this.toolbarClass = (isMobile ? "" : "tall");
    return this.updateStyles();
  },
  forward: function() {
    if (this.step < this.steps.length - 1 && this.gestureActive) {
      this.gestureActive = false;
      this.step++;
      return setTimeout(this.enableGesture, 200);
    }
  },
  back: function() {
    if (this.step > 0 && this.gestureActive) {
      this.gestureActive = false;
      this.step--;
      return setTimeout(this.enableGesture, 200);
    }
  },
  enableGesture: function() {
    return document.querySelector('x-app').gestureActive = true;
  }
});
