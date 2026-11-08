class Scorecard < CsvRecord
  csv_backed_by "scorecards.csv", columns: %w[
    user_name candidate_name submitted technical_skill communication collaboration role_fit notes
  ]

  validates :user_name, :candidate_name, presence: true
  validate :submission_date_must_be_valid
  validate :one_scorecard_per_user_and_candidate

  def self.identity_columns
    %w[user_name candidate_name]
  end

  private

  def submission_date_must_be_valid
    return if submitted.blank? || submitted.match?(/\A\d{4}-\d{2}-\d{2}\z/)

    errors.add(:submitted, "must be blank or use YYYY-MM-DD")
  end

  def one_scorecard_per_user_and_candidate
    existing = self.class.all.find do |record|
      record.user_name == user_name && record.candidate_name == candidate_name
    end
    return unless existing&.submitted.present?

    errors.add(:candidate_name, "already has a submitted scorecard for this user")
  end
end
