class VisitorsController < ApplicationController
  def index
    redirect_to user_path(current_user.login)
  end
end
