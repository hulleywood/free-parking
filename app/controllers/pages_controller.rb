class PagesController < ApplicationController
  def index
    @permit_url = "#{root_url}permits.json"
    @temporary_sign_url = "#{root_url}temporary_signs.json"
  end

  def file
    @url = params[:url]
  end
end
