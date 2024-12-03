class Loan < ApplicationRecord
  # Associations
  belongs_to :user # The user requesting the loan

  def self.ransackable_attributes(auth_object = nil)
    ["id", "user_id", "repaid_amount", "admin_id", "amount", "interest_rate", "total_interest", "last_updated_by", "total_amount", "state", "adjustments", "created_at", "updated_at"]
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
  before_save :calculate_total_amount

  # Scopes
  scope :open_loans, -> { where(state: 'open') }
  scope :requested_loans, -> { where(state: 'requested') }
  scope :approved_loans, -> { where(state: 'approved') }

  # Methods
  def approve!
    raise 'Loan cannot be approved in its current state' unless state == 'requested'

    update!(state: 'approved')
  end

  def reject!
    raise 'Loan cannot be rejected in its current state' unless %w[requested approved waiting_for_adjustment_acceptance].include?(state)

    update!(state: 'rejected')
  end

  def move_to_waiting_for_adjustment!
    raise 'Loan cannot be adjusted in its current state' unless state == 'approved'

    update!(state: 'waiting_for_adjustment_acceptance')
  end

  def request_readjustment!
    raise 'Loan cannot be readjusted in its current state' unless state == 'waiting_for_adjustment_acceptance'

    update!(state: 'readjustment_requested')
  end

  def close!
    raise 'Loan cannot be closed in its current state' unless state == 'open'

    update!(state: 'closed')
  end

  private

  # Default state setup
  def set_default_state
    self.state ||= 'requested'
  end

  # Calculate total loan amount based on interest
  def calculate_total_amount
    self.total_amount = amount + (amount * interest_rate / 100.0)
  end
end
