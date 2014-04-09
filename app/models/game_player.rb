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
    super(methods: :cash_to_english)
  end

  def get_username
    self.user.username
  end
end
