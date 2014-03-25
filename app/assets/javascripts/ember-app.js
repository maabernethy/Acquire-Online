window.App = Ember.Application.create();

App.ApplicationRoute = Ember.Route.extend({
  model: function() {
    return window.payload;
  },
});

App.GameBoardComponent = Ember.Component.extend({
  needs: ['application'],
  rows: [1,2,3,4,5,6,7,8,9,10,11,12],
  columns: ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I'],
  selectedHotel: {
    name: null
  },
  selectedHotelStock1: {
    name: null
  },
  selectedHotelStock2: {
    name: null
  },
  selectedHotelStock3: {
    name: null
  },
  save: function() {
    debugger;
    console.log('hello')
  },
  actions: {
    resolveIssue: function() {
      this.set('errored', false);
      console.log(this.get('selectedHotel').name);
      var _this = window.view;
      var cell = window.view.get('row') + window.view.get('column');
      Ember.$.ajax({
        url: '/games/'+window.payload.game.id+'/place_piece',
        data: {
          num: window.view.get('row'),
          letter: window.view.get('column'),
          cell: cell,
          hotel: this.get('selectedHotel').name
        }
      }).then(function(json) {
        if (json.answer.legal) {
          debugger;
          if (json.answer.other_tiles.length > 1) {
            json.answer.other_tiles.forEach(function(tile_info){
            _this.get('parentView').get('childViews')[tile_info[0]].set(tile_info[1], false);
            _this.get('parentView').get('childViews')[tile_info[0]].set(json.answer.color, true);
            });
          }
          else {
            _this.get('parentView').get('childViews')[json.answer.other_tiles].set(json.answer.color, true);
          };
          _this.set(json.answer.color, true);
          _this.set('controller.model.game', json.game);
          _this.set('controller.model.game_hotels', json.game_hotels);
          _this.set('controller.model.player', json.player);
          _this.set('controller.model.stocks', json.stocks);
          _this.set('controller.model.users', json.users);
          _this.set('controller.model.tiles', json.answer.new_tiles);
          _this.set('controller.model.available_hotels', json.available_hotels);
          _this.set('controller.model.board_colors', json.board_colors);
          _this.set('controller.model.founded_hotels', json.founded_hotels);
        }
      });
    },
    openStockOptions: function() {
      this.set('controller.open', true);
    },
    closeStockOptions: function() {
      this.set('controller.open', false);
      this.set('controller.buybutton', false);
      console.log(this.get('selectedHotelStock1').name);
      console.log(this.get('selectedHotelStock2').name);
      console.log(this.get('selectedHotelStock3').name);
      var _this = window.view;
      Ember.$.ajax({
        url: '/games/'+window.payload.game.id+'/buy_stocks',
        data: {
          hotel1: this.get('selectedHotelStock1').name,
          hotel2: this.get('selectedHotelStock2').name,
          hotel3: this.get('selectedHotelStock3').name
        }
      }).then(function(json) {
          _this.set('controller.model.game', json.game);
          _this.set('controller.model.game_hotels', json.game_hotels);
          _this.set('controller.model.player', json.player);
          _this.set('controller.model.stocks', json.stocks);
          _this.set('controller.model.users', json.users);
          _this.set('controller.model.available_hotels', json.available_hotels);
          _this.set('controller.model.board_colors', json.board_colors);
          _this.set('controller.model.founded_hotels', json.founded_hotels);
          none = new Object();
          none.name = 'none';
          json.founded_hotels.push(none);
          _this.set('controller.model.founded_hotels', json.founded_hotels);
          if(json.founded_hotels.length > 1) {
            _this.set('controller.buybutton', true);
          }
      });
    }
  }
});

App.GameBoardSquareView = Ember.View.extend({
  classNameBindings: ['isHover', 'color', 'grey', 'blue', 'yellow', 'red', 'green', 'orange', 'purple', 'pink'],
  mouseEnter: function() {
    this.set('isHover', true);
  },
  mouseLeave: function() {
    this.set('isHover', false);
  },
  init: function() {
    this._super();
    board_colors = this.get('board_colors');
    r = this.get('row');
    c = this.get('column');
    cell = r.toString() + c;
    color = board_colors[cell];
    if (typeof color != "undefined") {
      this.set(color, true);
    }
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
        if (json.answer.other_tiles != null) {
          if (json.answer.other_tiles[1] != 'grey') {
            debugger;
            json.answer.other_tiles.forEach(function(tile_info){
              _this.get('parentView').get('childViews')[tile_info[0]].set(tile_info[1], false);
              _this.get('parentView').get('childViews')[tile_info[0]].set(json.answer.color, true);
            });
          }
          else {
            debugger;
            tile_info = json.answer.other_tiles;
            _this.get('parentView').get('childViews')[tile_info[0]].set(tile_info[1], false);
            _this.get('parentView').get('childViews')[tile_info[0]].set(json.answer.color, true);
          };
        };
        _this.set('controller.model.game', json.game);
        _this.set('controller.model.game_hotels', json.game_hotels);
        _this.set('controller.model.player', json.player);
        _this.set('controller.model.stocks', json.stocks);
        _this.set('controller.model.users', json.users);
        _this.set('controller.model.tiles', json.answer.new_tiles);
        _this.set('controller.model.available_hotels', json.available_hotels);
        _this.set('controller.model.board_colors', json.board_colors);
        none = new Object();
        none.name = 'none';
        json.founded_hotels.push(none);
        _this.set('controller.model.founded_hotels', json.founded_hotels);
        if(json.founded_hotels.length > 1) {
          _this.set('controller.buybutton', true);
        }
      }
    }, function(json) {
      if (_this.get('controller.model.available_hotels').length != 0) {
        _this.set('controller.errored', true);
      }
      else {
        alert("All hotel chains are already founded! Place new piece.");
      }
    });
  },
});
