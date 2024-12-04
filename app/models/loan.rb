class Loan < ApplicationRecord
  belongs_to :user # The user requesting the loan

  def self.ransackable_attributes(auth_object = nil)
    ["id", "user_id", "repaid_amount", "admin_id", "amount", "interest_rate", "total_interest", "last_updated_by", "total_amount", "state", "adjustments", "created_at", "updated_at", "loan_credited_at"]
  end
  def self.ransackable_associations(auth_object = nil)
    ["admin", "user"]
  end

  # Loan states
  STATES = %w[requested approved rejected waiting_for_adjustment_acceptance readjustment_requested open closed].freeze

  # Validations
  validates :amount, presence: true, numericality: { greater_than: 0 }
  validates :interest_rate, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :state, inclusion: { in: STATES }

  # Callbacks
  before_validation :set_default_state, on: :create
  before_create :set_default_interest

  # Scopes
  scope :open_loans, -> { where(state: 'open') }
  scope :requested_loans, -> { where(state: 'requested') }
  scope :approved_loans, -> { where(state: 'approved') }

  # Calculate total loan amount based on interest by background job
  def calculate_interest
    return if state != 'open'
    return if loan_credited_at.nil?

    # Time elapsed since the loan was credited (in minutes)
    time_elapsed = (Time.current - loan_credited_at) / 60
    return if time_elapsed < 5

    # Calculate interest for the last 5-minute period
    interest = (amount * interest_rate * (time_elapsed / 5)) / (60 * 24 * 365)

    # Update the total interest and total amount
    new_total_amount = self.total_amount + interest
    self.total_amount = new_total_amount
    self.total_interest = (self.total_interest.to_f ||= 0.0) + interest

    begin
      Rails.logger.info("New Total Amount: #{new_total_amount}")
      Rails.logger.info("Current Total Amount Before Save: #{self.total_amount}")
      
      # Persist the changes to the loan record
      update_column(:total_amount, new_total_amount.round(2))
      update_column(:total_interest, self.total_interest.round(2)) if self.total_interest.present?

      Rails.logger.info("Loan ID: #{id} saved successfully with Total Amount: #{self.total_amount}")
    rescue => e
      Rails.logger.error("Error saving loan ID #{id}: #{e.message}")
    end
  end


  private

  # Default state setup
  def set_default_state
    self.state ||= 'requested'
  end


  # Default interest setup
  def set_default_interest
    self.total_interest ||= 0.0
    self.total_amount ||= amount
  end

end
