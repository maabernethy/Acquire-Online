window.App = Ember.Application.create();

App.ApplicationRoute = Ember.Route.extend({
  model: function() {
    return window.payload;
  }
});

App.GameBoardComponent = Ember.Component.extend({
  rows: [1,2,3,4,5,6,7,8,9,10,11,12],
  columns: ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I']
});

App.GameBoardSquareView = Ember.View.extend({
  tagName: 'td',
  classNameBindings: ['isHover', 'color'],
  mouseEnter: function() {
    this.set('isHover', true);
  },
  mouseLeave: function() {
    this.set('isHover', false)
  },
  click: function() {
    window.view = this;
    var _this = this;
    Ember.$.ajax({
      url: '/games/'+window.payload.game.id+'/place_piece',
      data: {
        num: this.get('row'),
        letter: this.get('column'),
        cell: this.get('row') + this.get('column')
      }
    }).then(function(json) {
      if (json.legal) {
        _this.set('color', json.color);
      }
    });
  }
});
