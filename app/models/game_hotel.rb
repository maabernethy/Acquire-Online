class GameHotel < ActiveRecord::Base
	belongs_to :game
	belongs_to :hotel

	WS = {
		0 => [100,0,0],
		2 => [200,2000,1000],
		3 => [300,3000,1500],
		4 => [400,4000,2000],
		5 => [500,5000,2500],
		6 => [600,6000,3000],
		11 => [700,7000,3500],
		21 => [800,8000,4000],
		31 => [900,9000,4500],
		41 => [1000,10000,5000]	
	}

	FIA = {
		0 => [200,0,0],
		2 => [300,3000,1500],
		3 => [400,4000,2000],
		4 => [500,5000,2500],
		5 => [600,6000,3000],
		6 => [700,7000,3500],
		11 => [800,8000,4000],
		21 => [900,9000,4500],
		31 => [1000,10000,5000],
		41 => [1100,11000,5500]	
	}

	CT = {
		0 => [300,0,0],
		2 => [400,4000,2000],
		3 => [500,5000,2500],
		4 => [600,6000,3000],
		5 => [700,7000,3500],
		6 => [800,8000,4000],
		11 => [900,9000,4500],
		21 => [1000,10000,5000],
		31 => [1100,11000,5500],
		41 => [1200,12000,6000]	
	}
	def update_share_price
		if self.name == 'Worldwide' || self.name == 'Sackson'
			if self.chain_size >= 0 && self.chain_size <= 6
				share_price = WS[self.chain_size][0]
			elsif self.chain_size < 11
				share_price = WS[6][0]
			elsif self.chain_size < 21
				share_price = WS[11][0]
			elsif self.chain_size < 31
				share_price = WS[21][0]
			elsif self.chain_size < 41
				share_price = WS[31][0]
			elsif self.chain_size >= 41
				share_price = WS[41][0]
			end
		elsif self.name == 'Continental' || self.name == 'Tower'
			if self.chain_size >= 0 && self.chain_size <= 6
				share_price = FIA[self.chain_size][0]
			elsif self.chain_size < 11
				share_price = FIA[6][0]
			elsif self.chain_size < 21
				share_price = FIA[11][0]
			elsif self.chain_size < 31
				share_price = FIA[21][0]
			elsif self.chain_size < 41
				share_price = FIA[31][0]
			elsif self.chain_size >= 41
				share_price = FIA[41][0]
			end
		elsif self.name == 'Festival' || self.name == 'Imperial' || self.name == 'American'
			if self.chain_size >= 0 && self.chain_size <= 6
				share_price = CT[self.chain_size][0]
			elsif self.chain_size < 11
				share_price = CT[6][0]
			elsif self.chain_size < 21
				share_price = CT[11][0]
			elsif self.chain_size < 31
				share_price = CT[21][0]
			elsif self.chain_size < 41
				share_price = CT[31][0]
			elsif self.chain_size >= 41
				share_price = CT[41][0]
			end
		end

		self.share_price = share_price
		self.save
	end

	def get_bonus_amounts(chain_size)
		if self.name == 'Worldwide' || self.name == 'Sackson'

			if chain_size >= 0 && chain_size <= 6
				majority = WS[chain_size][1]
				minority = WS[chain_size][2]
			elsif chain_size < 11
				majority = WS[6][1]
				minority = WS[6][2]
			elsif chain_size < 21
				majority = WS[21][1]
				minority = WS[21][2]
			elsif chain_size < 31
				majority = WS[11][1]
				minority = WS[11][2]
			elsif chain_size < 41
				majority = WS[31][1]
				minority = WS[31][2]
			elsif chain_size >= 41
				majority = WS[41][1]
				minority = WS[41][2]
			end

		elsif self.name == 'Continental' || self.name == 'Tower'
			if chain_size >= 0 && chain_size <= 6
				majority = FIA[chain_size][1]
				minority = FIA[chain_size][2]
			elsif chain_size < 11
				majority = FIA[6][1]
				minority = FIA[6][2]
			elsif chain_size < 21
				majority = FIA[11][1]
				minority = FIA[11][2]
			elsif chain_size < 31
				majority = FIA[21][1]
				minority = FIA[21][2]
			elsif chain_size < 41
				majority = FIA[31][1]
				minority = FIA[31][2]
			elsif chain_size >= 41
				majority = FIA[41][1]
				minority = FIA[41][2]
			end

		elsif self.name == 'Festival' || self.name == 'Imperial' || self.name == 'American'
			if chain_size >= 0 && chain_size <= 6
				majority = CT[chain_size][1]
				minority = CT[chain_size][2]
			elsif chain_size < 11
				majority = CT[6][1]
				minority = CT[6][2]
			elsif chain_size < 21
				majority = CT[11][1]
				minority = CT[11][2]
			elsif chain_size < 31
				majority = CT[21][1]
				minority = CT[21][2]
			elsif chain_size < 41
				majority = CT[31][1]
				minority = CT[31][2]
			elsif chain_size >= 41
				majority = CT[41][1]
				minority = CT[41][2]
			end

		end

		[majority, minority]
	end
end
