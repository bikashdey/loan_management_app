class LoansController < ApplicationController
  include JwtAuthentication
  before_action  :authenticate_request
  before_action :set_loan, only: [:update_loan, :repay]


  # POST /loans
  def create
    authorize Loan, :create? # Authorization check for loan creation
    loan = current_user.loans.new(loan_params.merge(state: 'requested'))
    if loan.save
      render json: loan, status: :created
    else
      render json: { errors: loan.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # PATCH /loans/:id/update_loan
  def update_loan
    # this update 
    action_type = params[:action_type]
    authorize @loan, "#{action_type}?".to_sym

    case action_type
    when 'accept_loan'
      process_loan_acceptance
    when 'reject_loan'
      process_loan_rejection
    when 'request_readjustment'
      process_readjustment_request
    when 'accept_adjustment'
      process_adjustment_acceptance
    when 'reject_adjustment'
      process_adjustment_rejection
    else
      render json: { error: 'Invalid action type' }, status: :unprocessable_entity
    end
  end

  # PUT /loans/:id/repay
  def repay
    authorize @loan, :repay? # Authorization for repayment
    if @loan.state != "open"
      return render json: { error: "Loan not open for repayment" }, status: :unprocessable_entity
    end

    repayment = [@loan.total_amount, current_user.wallet].min
    ActiveRecord::Base.transaction do
      current_user.update!(wallet: current_user.wallet - repayment)
      admin.update!(wallet: admin.wallet + repayment)

      if repayment == @loan.total_amount
        @loan.update!(state: "closed")
      end
    end

    render json: { status: "Repayment successful", remaining_wallet: current_user.wallet }
  end

  private

  def set_loan
    @loan = current_user.loans.find(params[:id]) # Restrict to current user's loans
  end

  def loan_params
    params.require(:loan).permit(:amount, :interest_rate)
  end

  def admin
    #only one admin present in this app
    AdminUser&.first
  end

  # Helper methods for loan actions
  def process_loan_acceptance
    if @loan.state == 'approved'
      @loan.update!(state: 'open', last_updated_by: 'user')
      # Debit admin and credit user
      admin.update!(wallet: admin.wallet - @loan.amount)
      current_user.update!(wallet: current_user.wallet + @loan.amount)
      render json: { message: 'Loan accepted and moved to open state' }
    else
      render json: { error: 'Loan cannot be accepted at this stage' }, status: :unprocessable_entity
    end
  end

  def process_loan_rejection
    if %w[approved waiting_for_adjustment_acceptance].include?(@loan.state)
      @loan.update!(state: 'rejected', last_updated_by: 'user')
      render json: { message: 'Loan rejected' }
    else
      render json: { error: 'Loan cannot be rejected at this stage' }, status: :unprocessable_entity
    end
  end

  def process_readjustment_request
    if @loan.state == 'waiting_for_adjustment_acceptance'
      @loan.update!(state: 'readjustment_requested', last_updated_by: 'user')
      render json: { message: 'Readjustment requested' }
    else
      render json: { error: 'Loan cannot be readjusted at this stage' }, status: :unprocessable_entity
    end
  end

  def process_adjustment_acceptance
    if @loan.state == 'waiting_for_adjustment_acceptance'
      @loan.update!(state: 'open', last_updated_by: 'user')
      # Debit admin and credit user
      admin.update!(wallet: admin.wallet - @loan.amount)
      current_user.update!(wallet: current_user.wallet + @loan.amount)
      render json: { message: 'Adjustment accepted and loan moved to open state' }
    else
      render json: { error: 'Adjustment cannot be accepted at this stage' }, status: :unprocessable_entity
    end
  end

  def process_adjustment_rejection
    if @loan.state == 'waiting_for_adjustment_acceptance'
      @loan.update!(state: 'rejected', last_updated_by: 'user')
      render json: { message: 'Adjustment rejected' }
    else
      render json: { error: 'Adjustment cannot be rejected at this stage' }, status: :unprocessable_entity
    end
  end
end
