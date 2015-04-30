class PagesController < ApplicationController
  def index
    @show_cluster = request.fullpath == '/marker' ? false : true
  end
end
