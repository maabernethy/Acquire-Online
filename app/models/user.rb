class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, authentication_keys: [:username]
  has_many :game_players
  has_many :games, through: :game_players

  def online?
    updated_at > 10.minutes.ago
  end
end
