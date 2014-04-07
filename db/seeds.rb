# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

#Make all tiles on board
%w(A B C D E F G H I).each do |row|
  %w(1 2 3 4 5 6 7 8 9 10 11 12).each do |column|
    Tile.create(row: row, column: column)
  end
end

#Make all stock_cards
%w(American Continental Festival Imperial Sackson Tower Worldwide).each do |hotel|
  %w(1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25).each do |card_number|
    StockCard.create(hotel: hotel, card_number: card_number)
  end
end

#Make all hotels
hotel = ['American', 'Continental', 'Festival', 'Imperial', 'Sackson', 'Tower', 'Worldwide']
color = ['blue', 'yellow', 'red', 'green', 'orange', 'purple', 'pink']
hotel.zip(color) do |hotel, color|
	Hotel.create(name: hotel, color: color)
end