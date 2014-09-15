class ScreensController < ApplicationController

	def index
		@screens = Screen.all
	end

	def slideshow
		@screens = Screen.all
	end

	def new
		@screen = Screen.new
	end

	def show
		@screen = Screen.find(params[:id])
	end

	def edit
		@screen = Screen.find(params[:id])
	end

	def update
		@screen = Screen.find(params[:id])
		if @screen.update(params[:screen].permit(:title, :text))
			broadcast("/screens", @screen, "edit")
			redirect_to @screen
		else
			render 'edit'
		end
	end

	def create
		#render text: params[:screen].inspect
		@screen = Screen.new(params[:screen].permit(:title, :text))
		if @screen.save
			#broadcast("/screens/#{@screen}", @screen)
			broadcast("/screens", @screen, "create")
			redirect_to @screen
		else
			render 'new'
		end
	end

	def destroy
		@screen = Screen.find(params[:id])
		@screen.destroy
		broadcast("/screens", @screen, "destroy")
		redirect_to screens_path
	end

  private

    def broadcast(channel, object, type)
      screen = {:channel => channel, :data => {:object => object, :channel => channel, :type => type}, :ext => {:auth_token => FAYE_TOKEN}}
      uri = URI.parse("http://localhost:9292/faye")
      Net::HTTP.post_form(uri, :message => screen.to_json)
    end

end
