require "csv"
require "fileutils"
require "tempfile"

# Small Active Model base for records persisted directly to the supplied CSVs.
# The CSV headers are the schema; subclasses must declare those exact columns.
class CsvRecord
  include ActiveModel::Model

  class << self
    attr_reader :csv_columns, :csv_filename

    def csv_backed_by(filename, columns:)
      @csv_filename = filename
      @csv_columns = columns.map(&:to_s).freeze
      attr_accessor(*@csv_columns.map(&:to_sym))
    end

    def all
      return [] unless File.exist?(csv_path)

      CSV.read(csv_path, headers: true, encoding: "bom|utf-8").map do |row|
        new(row.to_h)
      end
    end

    def csv_path
      Rails.root.join("db", csv_filename)
    end

    # def with_csv_lock
    #   lock_path = "#{csv_path}.lock"
    #   FileUtils.mkdir_p(File.dirname(lock_path))
    #   File.open(lock_path, File::RDWR | File::CREAT, 0o644) do |lock|
    #     lock.flock(File::LOCK_EX)
    #     yield
    #   ensure
    #     lock.flock(File::LOCK_UN)
    #   end
    # end

    def write_records(records)
      with_csv_lock do
        Tempfile.create(["#{File.basename(csv_filename)}-", ".tmp"], File.dirname(csv_path)) do |temporary|
          CSV.open(temporary.path, "w", write_headers: true, headers: csv_columns) do |csv|
            records.each { |record| csv << csv_columns.map { |column| record.public_send(column) } }
          end
          FileUtils.mv(temporary.path, csv_path, force: true)
        end
      end
    end
  end

  # def save
  #   persisted = false
  #   self.class.with_csv_lock do
  #     next unless valid?

  #     records = self.class.all
  #     existing_index = records.index { |record| same_record?(record) }
  #     existing_index ? records[existing_index] = self : records << self
  #     write_records_without_lock(records)
  #     persisted = true
  #   end
  #   persisted
  # end

  private

  # def same_record?(record)
  #   self.class.identity_columns.all? do |column|
  #     record.public_send(column).to_s == public_send(column).to_s
  #   end
  # end

  # def write_records_without_lock(records)
  #   Tempfile.create(["#{File.basename(self.class.csv_filename)}-", ".tmp"], File.dirname(self.class.csv_path)) do |temporary|
  #     CSV.open(temporary.path, "w", write_headers: true, headers: self.class.csv_columns) do |csv|
  #       records.each { |record| csv << self.class.csv_columns.map { |column| record.public_send(column) } }
  #     end
  #     FileUtils.mv(temporary.path, self.class.csv_path, force: true)
  #   end
  # end
end
