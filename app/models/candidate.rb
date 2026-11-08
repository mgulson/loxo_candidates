class Candidate < CsvRecord
  csv_backed_by "candidates.csv", columns: %w[name role hiring_manager]

  validates :name, :role, :hiring_manager, presence: true
  validate :name_must_be_unique

  def self.identity_columns
    %w[name]
  end

  private

  def name_must_be_unique
    duplicate = self.class.all.any? { |candidate| candidate.name == name }
    errors.add(:name, "has already been taken") if duplicate
  end
end
