class SlideshowsController < ApplicationController

	def index
		@screens = Screen.all
	end

end
