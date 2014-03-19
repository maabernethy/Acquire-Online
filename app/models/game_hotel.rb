class GameHotel < ActiveRecord::Base
	belongs_to :game
	belongs_to :hotel

	WS = {
		0 => 100,
		2 => 200,
		3 => 300,
		4 => 400,
		5 => 500,
		6 => 600,
		11 => 700,
		21 => 800,
		31 => 900,
		41 => 1000	
	}

	FIA = {
		0 => 200,
		2 => 300,
		3 => 400,
		4 => 500,
		5 => 600,
		6 => 700,
		11 => 800,
		21 => 900,
		31 => 1000,
		41 => 1100	
	}

	CT = {
		0 => 300,
		2 => 400,
		3 => 500,
		4 => 600,
		5 => 700,
		6 => 800,
		11 => 900,
		21 => 1000,
		31 => 1100,
		41 => 1200	
	}
	def update_share_price
		byebug
		if self.name == 'Worldwide' || self.name == 'Sackson'
			byebug
			if self.chain_size >= 0 && self.chain_size <= 6
				share_price = WS[self.chain_size]
			elsif self.chain_size < 11
				share_price = WS[6]
			elsif self.chain_size < 21
				share_price = WS[11]
			elsif self.chain_size < 31
				share_price = WS[21]
			elsif self.chain_size < 41
				share_price = WS[31]
			elsif self.chain_size >= 41
				share_price = WS[41]
			end
		elsif self.name == 'Continental' || self.name == 'Tower'
			byebug
			if self.chain_size >= 0 && self.chain_size <= 6
				share_price = FIA[self.chain_size]
			elsif self.chain_size < 11
				share_price = FIA[6]
			elsif self.chain_size < 21
				share_price = FIA[11]
			elsif self.chain_size < 31
				share_price = FIA[21]
			elsif self.chain_size < 41
				share_price = FIA[31]
			elsif self.chain_size >= 41
				share_price = FIA[41]
			end
		elsif self.name == 'Festival' || self.name == 'Imperial' || self.name == 'American'
			byebug
			if self.chain_size >= 0 && self.chain_size <= 6
				share_price = CT[self.chain_size]
			elsif self.chain_size < 11
				share_price = CT[6]
			elsif self.chain_size < 21
				share_price = CT[11]
			elsif self.chain_size < 31
				share_price = CT[21]
			elsif self.chain_size < 41
				share_price = CT[31]
			elsif self.chain_size >= 41
				share_price = CT[41]
			end
		end
		byebug
		self.share_price = share_price
		self.save
	end
end
