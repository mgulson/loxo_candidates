class User < CsvRecord
  csv_backed_by "users.csv", columns: %w[name role]

  validates :name, :role, presence: true

  def self.identity_columns
    %w[name]
  end
end
