class Balance < ApplicationRecord
  self.primary_key = 'moneyforward_id'

  belongs_to :large_category, class_name: 'Category', foreign_key: 'large_category_id'
  belongs_to :medium_category, class_name: 'Category', foreign_key: 'medium_category_id'

  delegate :name, to: :large_category, prefix: true
  delegate :name, to: :medium_category, prefix: true

  scope :calculating_target, -> { where(calculating_target_flag: true) }
  scope :total_price, -> { calculating_target.sum(:price) }

  class << self
    def import!(file)
      CSV.foreach(file.path, headers: true, encoding: 'Windows-31J:UTF-8') do |row|
        balance = find_or_initialize_by(moneyforward_id: row['ID'])

        columns.each do |column|
          if %w[large_category_id medium_category_id].include?(column.name)
            category = Category.find_or_initialize_by(name: row[column.comment])
            next balance[column.name] = category.id if category.id.present?

            category.size = 2 if column.name == 'medium_category_id'
            category.save
            next balance[column.name] = category.id
          end
          if column.name == 'financial_facility_id'
            financial_facility = FinancialFacility.find_or_initialize_by(name: row[column.comment])
            next balance[column.name] = financial_facility.id if financial_facility.id.present?

            financial_facility.save
            next balance[column.name] = financial_facility.id
          end

          balance[column.name] = row[column.comment] if row[column.comment].present?
        end

        balance.save!
      end
    end
  end
end
