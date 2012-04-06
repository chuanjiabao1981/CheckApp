class SupervisorController < ApplicationController
  before_filter :signed_in_user, only: [:home]
  before_filter :correct_user,   only: [:home]

  def home
  end

  private

    def signed_in_user
      redirect_to signin_path, notice: "Please sign in." unless signed_in?
    end

    def correct_user
      redirect_to(root_path) unless signed_in? and current_user.supervisor?
    end

end
