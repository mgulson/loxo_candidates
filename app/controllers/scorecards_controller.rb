class ScorecardsController < ApplicationController
  before_action :require_current_user

  def new
    @candidate = Candidate.all.find { |record| record.name == params[:candidate_name] }
    return redirect_to candidates_path, alert: "Candidate not found." unless @candidate

    @scorecard = assigned_scorecard(@candidate)
    return redirect_to candidate_path(name: @candidate.name), alert: "You are not assigned to this candidate." unless @scorecard
    return redirect_to candidate_path(name: @candidate.name), alert: "You have already submitted a scorecard." if @scorecard.submitted.present?
  end

  def create
    candidate = Candidate.all.find { |record| record.name == params[:candidate_name] }
    return redirect_to candidates_path, alert: "Candidate not found." unless candidate

    @scorecard = assigned_scorecard(candidate)
    return redirect_to candidate_path(name: candidate.name), alert: "You are not assigned to this candidate." unless @scorecard
    return redirect_to candidate_path(name: candidate.name), alert: "You have already submitted a scorecard." if @scorecard.submitted.present?

    @scorecard.assign_attributes(scorecard_params.merge(submitted: Date.current.iso8601))
    if @scorecard.save
      redirect_to candidate_path(name: candidate.name), notice: "Your scorecard was submitted."
    else
      @candidate = candidate
      render :new, status: :unprocessable_entity
    end
  end

  private

  def assigned_scorecard(candidate)
    Scorecard.all.find do |scorecard|
      scorecard.candidate_name == candidate.name && scorecard.user_name == current_user.name
    end
  end

  def scorecard_params
    params.require(:scorecard).permit(:technical_skill, :communication, :collaboration, :role_fit, :notes).to_h
  end
end
