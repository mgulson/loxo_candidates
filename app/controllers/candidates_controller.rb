class CandidatesController < ApplicationController
  before_action :require_current_user

  def index
    @candidates = Candidate.all
    @managed_candidates = @candidates.select { |candidate| candidate.hiring_manager == current_user.name }
    @assigned_candidates = @candidates.select do |candidate|
      candidate.hiring_manager != current_user.name && assigned_to?(candidate)
    end
  end

  def show
    @candidate = Candidate.all.find { |candidate| candidate.name == params[:name] }
    return redirect_to candidates_path, alert: "Candidate not found." unless @candidate

    @scorecards = Scorecard.all.select { |scorecard| scorecard.candidate_name == @candidate.name }
    @is_manager = @candidate.hiring_manager == current_user.name
    @my_scorecard = @scorecards.find { |scorecard| scorecard.user_name == current_user.name }
    unless @is_manager || @my_scorecard
      return redirect_to candidates_path, alert: "You are not assigned to this candidate."
    end

    @submitted_scorecards = @scorecards.select { |scorecard| scorecard.submitted.present? }
    @assignable_users = User.all.reject do |user|
      user.name == @candidate.hiring_manager || @scorecards.any? { |scorecard| scorecard.user_name == user.name }
    end
  end

  def new
    @candidate = Candidate.new
  end

  def create
    @candidate = Candidate.new(candidate_params.merge(hiring_manager: current_user.name))
    if @candidate.save
      redirect_to candidate_path(name: @candidate.name), notice: "Candidate added."
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def candidate_params
    params.require(:candidate).permit(:name, :role).to_h
  end

  def assigned_to?(candidate)
    Scorecard.all.any? { |scorecard| scorecard.candidate_name == candidate.name && scorecard.user_name == current_user.name }
  end
end
