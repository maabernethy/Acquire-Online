class NotificationsController < ApplicationController
	def destroy
		@notification = Notification.find params[:id]
    	@notification.destroy
    	redirect_to game_center_path
	end
end