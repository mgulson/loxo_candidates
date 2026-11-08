class UsersController < ApplicationController
  before_action :require_current_user, only: :index

  def index
    @users = User.all
    @managed_candidates = Candidate.all.select { |candidate| candidate.hiring_manager == current_user.name }
    @assigned_candidates = Candidate.all.select do |candidate|
      candidate.hiring_manager != current_user.name &&
        Scorecard.all.any? { |scorecard| scorecard.candidate_name == candidate.name && scorecard.user_name == current_user.name }
    end
  end

  def select
    user = User.all.find { |record| record.name == params[:user_name] }
    if user
      session[:current_user_name] = user.name
      redirect_to root_path, notice: "Viewing as #{user.name}."
    else
      redirect_to root_path, alert: "Choose a user from the provided users list."
    end
  end
end
