window.App = Ember.Application.create();

App.ApplicationRoute = Ember.Route.extend({
  model: function() {
    return window.payload;
  },
});

Handlebars.registerHelper('ifShares', function(v1, options) {
  var v = this.get('controller.model.game.has_shares')
  if(v > 0) {
    return options.fn(this);
  }
  return options.inverse(this);
});

Handlebars.registerHelper('ifEnough', function(v1, options) {
  var v = this.get('controller.model.hotels_w_enough_stock_cards').length
  if(v > 1) {
    return options.fn(this);
  }
  return options.inverse(this);
});



App.GameBoardComponent = Ember.Component.extend({
  init: function(){
    this._super();
    var p1 = this.get('controller.model.player.username')
    var p2 = this.get('controller.model.game.merger_up_next')
    if(p1 === p2) {
      this.set('controller.merger_hold_sell_button', true)
    }
    var v = this.get('controller.model.player.buy_stocks')
    if(v == true) {
      this.set('controller.buybutton', true)
    }
  },
  needs: ['application'],
  rows: [1,2,3,4,5,6,7,8,9,10,11,12],
  columns: ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I'],
  options: ['Hold', 'Sell', 'Trade'],
  holdNumber: null,
  tradeNumber: null,
  sellNumber: null,
  tradeHotel: {
    name: null
  },
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
  selectedOption: {
    name: 'none'
  },
  alert: '',
  actions: {
    resolveIssue: function() { // called when player is done selected hotel chain they want to found
      this.set('errored', false);
      console.log(this.get('selectedHotel').name);
      var _this = window.view;
      var cell = window.view.get('row') + window.view.get('column');
      Ember.$.ajax({ // request to server
        url: '/games/'+window.payload.game.id+'/place_piece',
        data: {
          num: window.view.get('row'),
          letter: window.view.get('column'),
          cell: cell,
          hotel: this.get('selectedHotel').name
        }
      }).then(function(json) { // invoked upon successful response from server
        if (json.answer.legal) {
          // changing color of necessary tiles
          if (json.answer.other_tiles.length > 1) {
            json.answer.other_tiles.forEach(function(tile_info){
            _this.get('parentView').get('childViews')[tile_info[0]].set(tile_info[1], false);
            _this.get('parentView').get('childViews')[tile_info[0]].set(json.answer.color, true);
            });
          }
          else {
            _this.get('parentView').get('childViews')[json.answer.other_tiles].set(json.answer.color, true);
          };
          // saving updated data in ember models so that template can update information
          _this.set(json.answer.color, true);
          _this.set('controller.model.game', json.game);
          _this.set('controller.model.game_hotels', json.game_hotels);
          _this.set('controller.model.player', json.player);
          _this.set('controller.model.stocks', json.stocks);
          _this.set('controller.model.players', json.players);
          _this.set('controller.model.tiles', json.answer.new_tiles);
          _this.set('controller.model.available_hotels', json.available_hotels);
          _this.set('controller.model.board_colors', json.board_colors);
          _this.set('controller.model.founded_hotels', json.founded_hotels);
          _this.set('controller.model.log_entries', json.log_entries);
          _this.set('controller.model.acquired_hotel', json.answer.acquired_hotel);
          none = new Object();
          none.name = 'none';
          json.hotels_w_enough_stock_cards.push(none);
          _this.set('controller.model.hotels_w_enough_stock_cards', json.hotels_w_enough_stock_cards);
          _this.set('controller.buybutton', true)
        }
      });
    },
    openMergerOptions: function() {
      this.set('controller.open_merger', true);
    },
    closeMergerOptions: function(shares) { // called when player has selected whether to hold sell or trade shares
      var hnum = this.get('holdNumber');
      var tnum = this.get('tradeNumber');
      var snum = this.get('sellNumber');
      var num_shares = this.get('controller.model.game.has_shares')
      // determine whether user input is correct
      if (tnum == null) {
        var total = parseInt(hnum) + parseInt(snum)
      }
      else {
        var total = parseInt(hnum) + parseInt(snum) + parseInt(tnum)
      }
      if (shares == false) {
        this.set('alert', '')
      }
      else if (tnum % 2 != 0) {
        this.set('alert', 'trade shares must be even number')
      }
      else if (hnum == '' || tnum == '' || snum == '') {
        this.set('alert', 'only use integers')
      }
      else if (total != num_shares) {
        this.set('alert', 'numbers do not add up correctly')
      }
      else {
        this.set('alert', '')
      }
      if (this.get('alert') == '') {
        this.set('controller.merger_hold_sell_button', false);
        this.set('controller.open_merger', false);
        this.set('controller.model.has_shares', false);
        acquired_hotel = this.get('controller.model.game.acquired_hotel')
        var _this = this;
        Ember.$.ajax({
          url: '/games/'+window.payload.game.id+'/merger_turn',
          data: {
            acquired_hotel: acquired_hotel,
            shares: shares,
            hold: hnum,
            sell: snum,
            trade: tnum,
          }
        }).then(function(json) { // invoked when successful response from server
          if(json.game_over) {
            _this.set('controller.winner', json.winner);
            _this.set('controller.game_over', true);
          }
          else {
            // updated data saved in ember models to that template updates information in view
            _this.set('controller.model.game', json.game);
            _this.set('controller.model.game_hotels', json.game_hotels);
            _this.set('controller.model.player', json.player);
            _this.set('controller.model.stocks', json.stocks);
            _this.set('controller.model.players', json.players);
            _this.set('controller.model.available_hotels', json.available_hotels);
            _this.set('controller.model.board_colors', json.board_colors);
            _this.set('controller.model.founded_hotels', json.founded_hotels);
            _this.set('controller.model.log_entries', json.log_entries);
            _this.set('controller.merger_hold_sell_button', false);
            _this.set('holdNumber', null);
            _this.set('tradeNumber', null);
            _this.set('sellNumber', null);
          }
        });
      }
    },
    openStockOptions: function() {
      this.set('controller.open', true);
    },
    closeStockOptions: function() { // called when player has selected what stock they want to purchase
      this.set('controller.open', false);
      this.set('controller.buybutton', false);
      console.log(this.get('selectedHotelStock1').name);
      console.log(this.get('selectedHotelStock2').name);
      console.log(this.get('selectedHotelStock3').name);
      var _this = this;
      Ember.$.ajax({
        url: '/games/'+window.payload.game.id+'/buy_stocks',
        data: {
          hotel1: this.get('selectedHotelStock1').name,
          hotel2: this.get('selectedHotelStock2').name,
          hotel3: this.get('selectedHotelStock3').name
        }
      }).then(function(json) { //invoked upon successful response from server
          if(json.game_over) {
            _this.set('controller.winner', json.winner);
            _this.set('controller.game_over', true);
          }
          else {
            // updated data saved in ember models to that template updates information in view
            _this.set('controller.model.game', json.game);
            _this.set('controller.model.game_hotels', json.game_hotels);
            _this.set('controller.model.player', json.player);
            _this.set('controller.model.stocks', json.stocks);
            _this.set('controller.model.players', json.players);
            _this.set('controller.model.available_hotels', json.available_hotels);
            _this.set('controller.model.board_colors', json.board_colors);
            _this.set('controller.model.founded_hotels', json.founded_hotels);
            _this.set('controller.model.log_entries', json.log_entries);
            _this.set('controller.buybutton', false);
            none = new Object();
            none.name = 'none';
            json.hotels_w_enough_stock_cards.push(none);
            _this.set('controller.model.hotels_w_enough_stock_cards', json.hotels_w_enough_stock_cards);
            if(json.hotels_w_enough_stock_cards.length > 1) {
              _this.set('controller.buybutton', false);
            }
          }
      });
    }
  }
});

App.GameBoardSquareView = Ember.View.extend({
  classNameBindings: ['isHover', 'color', 'grey', 'blue', 'yellow', 'red', 'green', 'orange', 'purple', 'pink'],
  colors: ['blue', 'yellow', 'red', 'green', 'orange', 'pink', 'purple'],
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
    }).then(function(json) { //invoked upon successful response from server when placing tile
      if (json.answer.legal) {
        //changing color of necessary tiles
        _this.set(json.answer.color, true);
        if (json.answer.other_tiles != null) {
          if (json.answer.other_tiles[1] != 'grey') {
            json.answer.other_tiles.forEach(function(tile_info){
              _this.get('parentView').get('childViews')[tile_info[0]].set(tile_info[1], false);
              _this.get('parentView').get('childViews')[tile_info[0]].set(json.answer.color, true);
            });
          }
          else {
            tile_info = json.answer.other_tiles;
            _this.get('parentView').get('childViews')[tile_info[0]].set(tile_info[1], false);
            _this.get('parentView').get('childViews')[tile_info[0]].set(json.answer.color, true);
          };
        };
        // updated data saved in ember models to that template updates information in view
        _this.set('controller.model.game', json.game);
        _this.set('controller.model.game_hotels', json.game_hotels);
        _this.set('controller.model.player', json.player);
        _this.set('controller.model.stocks', json.stocks);
        _this.set('controller.model.players', json.players);
        _this.set('controller.model.tiles', json.answer.new_tiles);
        _this.set('controller.model.available_hotels', json.available_hotels);
        _this.set('controller.model.board_colors', json.board_colors);
        _this.set('controller.model.founded_hotels', json.founded_hotels);
        _this.set('controller.model.acquired_hotel', json.answer.acquired_hotel);
        _this.set('controller.model.log_entries', json.log_entries);
        none = new Object();
        none.name = 'none';
        json.hotels_w_enough_stock_cards.push(none);
        _this.set('controller.model.hotels_w_enough_stock_cards', json.hotels_w_enough_stock_cards);
        if (json.answer.merger) { // if merger, then button should appear with options
          console.log('merger!');
          _this.set('controller.merger_hold_sell_button', true);
          if (!json.answer.has_shares) {
            _this.set('controller.model.has_shares', false);
          }
          if (json.answer.has_shares) {
            _this.set('controller.model.has_shares', true);
          }
        }
        else {
          if(json.hotels_w_enough_stock_cards.length > 1) {
            _this.set('controller.buybutton', true);
          }
        }
      }
    }, function(json) { // invoked when unsuccessful response from server, this means need input from user on which hotel to found
      if (_this.get('controller.model.available_hotels').length != 0) {
        _this.set('controller.errored', true);
      }
      else {
        alert("All hotel chains are already founded! Place new piece.");
      }
    });
  },
});
