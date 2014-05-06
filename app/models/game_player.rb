class GamePlayer < ActiveRecord::Base
  belongs_to :user
  belongs_to :game
  has_many :game_player_tiles
  has_many :tiles, through: :game_player_tiles
  has_many :game_player_stock_cards
  has_many :stock_cards, through: :game_player_stock_cards

  def cash_to_english
    '$' + cash.to_s
  end

  def stock_cards_by_name_payload
    stocks = []
    stock_cards.map(&:hotel).uniq.each do |hotel|
      stocks << { name: hotel, amount: stock_cards.where(hotel: hotel).count }
    end
    stocks
  end

  def as_json(*)
    super(methods: [:cash_to_english, :get_stocks_american, :get_stocks_tower, :get_stocks_imperial, :get_stocks_festival, :get_stocks_sackson, :get_stocks_worldwide, :get_stocks_continental])
  end

  def get_username
    self.user.username
  end

  def get_stocks_american
    stock_cards.where(hotel: 'American').count
  end

  def get_stocks_tower
    stock_cards.where(hotel: 'Tower').count
  end

  def get_stocks_imperial
    stock_cards.where(hotel: 'Imperial').count
  end

  def get_stocks_festival
    stock_cards.where(hotel: 'Festival').count
  end
   
  def get_stocks_sackson
    stock_cards.where(hotel: 'Sackson').count
  end

  def get_stocks_worldwide
    stock_cards.where(hotel: 'Worldwide').count
  end

  def get_stocks_continental
    stock_cards.where(hotel: 'Continental').count
  end
end
