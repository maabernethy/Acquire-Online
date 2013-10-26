class LandingController < ApplicationController
  def show
  end

  def after_sign_in_path_for(resource)
    game_center_path
  end
end
