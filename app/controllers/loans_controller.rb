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
    authorize @loan, :repay?
    if @loan.state != "open"
      return render json: { error: "Loan not open for repayment" }, status: :unprocessable_entity
    end
    
    remaining_amount_to_repay = @loan.total_amount - @loan.repaid_amount
    #its take the min amount for repayment may be user wallet have more amount the loan amount
    repayment = [@loan.total_amount, current_user.wallet, remaining_amount_to_repay].min
    return render json: { error: "Insufficient fund to Repay"} , status: 422 if repayment < 0
    ActiveRecord::Base.transaction do

      current_user.update!(wallet: current_user.wallet - repayment)
      admin.update!(wallet: admin.wallet + repayment)
      @loan.update!(repaid_amount: @loan.repaid_amount + repayment )

      # if total amount is equal to repaid amount that means loan is repaid now we can close the loan
      if @loan.total_amount == @loan.repaid_amount
        @loan.update!(state: "closed",last_updated_by: 'user')
      end

    end

    render json: { status: "Repayment successful", remaining_wallet: current_user.wallet , loan_state: @loan.state }
  end

  private

  def set_loan
    @loan = current_user.loans.find(params[:id])
  end

  def loan_params
    params.require(:loan).permit(:amount, :interest_rate)
  end

  def admin
    #only one admin present in this app
    AdminUser&.first
  end

  def process_loan_acceptance
    if @loan.state == 'approved'
      @loan.update!(state: 'open', last_updated_by: 'admin')

      # Find the admin responsible for the approval
      if admin.wallet >= @loan.amount
        # Debit admin's wallet and credit user's wallet
        admin.update!(wallet: admin.wallet - @loan.amount)
        @loan.user.update!(wallet: @loan.user.wallet + @loan.amount)

        render json: { message: 'Loan accepted and moved to open state' }, status: :ok
      else
        render json: { error: 'Insufficient funds in admin wallet' }, status: :unprocessable_entity
      end
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
