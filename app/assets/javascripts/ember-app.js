window.App = Ember.Application.create();

App.ApplicationRoute = Ember.Route.extend({
  model: function() {
    return window.payload;
  }
});

App.GameBoardComponent = Ember.Component.extend({
  needs: ['application'],
  rows: [1,2,3,4,5,6,7,8,9,10,11,12],
  columns: ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I']
});

App.GameBoardSquareView = Ember.View.extend({
  tagName: 'td',
  classNameBindings: ['isHover', 'color', 'grey', 'blue', 'yellow', 'red', 'green', 'orange', 'purple', 'pink'],
  mouseEnter: function() {
    this.set('isHover', true);
  },
  mouseLeave: function() {
    this.set('isHover', false)
  },
  click: function() {
    window.view = this;
    var _this = this;
    var cell = this.get('row') + this.get('column');
    Ember.$.ajax({
      url: '/games/'+window.payload.game.id+'/place_piece',
      data: {
        num: this.get('row'),
        letter: this.get('column'),
        cell: cell
      }
    }).then(function(json) {
      if (json.answer.legal) {
        _this.set(json.answer.color, true);
        _this.set('controller.model.game', json.game);
        _this.set('controller.model.game_hotels', json.game_hotel);
        _this.set('controller.model.player', json.player);
        _this.set('controller.model.stocks', json.stocks);
        _this.set('controller.model.users', json.users);
        _this.set('controller.model.tiles', json.answer.new_tiles);
      }
    }, function(json) {
      debugger;
    });
  },
});
