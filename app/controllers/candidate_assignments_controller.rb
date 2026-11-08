class CandidateAssignmentsController < ApplicationController
  before_action :require_current_user

  def create
    candidate = Candidate.all.find { |record| record.name == params[:name] }
    return redirect_to candidates_path, alert: "Candidate not found." unless candidate
    return redirect_to candidate_path(name: candidate.name), alert: "Only the hiring manager can assign reviewers." unless candidate.hiring_manager == current_user.name

    user = User.all.find { |record| record.name == params[:user_name] }
    return redirect_to candidate_path(name: candidate.name), alert: "Choose a valid user other than the hiring manager." unless user && user.name != candidate.hiring_manager

    already_assigned = Scorecard.all.any? do |scorecard|
      scorecard.candidate_name == candidate.name && scorecard.user_name == user.name
    end
    if already_assigned
      redirect_to candidate_path(name: candidate.name), alert: "That user is already assigned."
    elsif Scorecard.new(user_name: user.name, candidate_name: candidate.name).save
      redirect_to candidate_path(name: candidate.name), notice: "#{user.name} was assigned to review this candidate."
    else
      redirect_to candidate_path(name: candidate.name), alert: "The assignment could not be saved."
    end
  end
end
