ActiveAdmin.register Loan do
  actions :index, :show, :edit, :update

  # Permitted parameters for form submissions
  permit_params :amount,:last_updated_by, :interest_rate, :state, :user_id, :admin_id, :loan_adjustment_amount, :loan_adjustment_interest_rate
  
  scope :all
  scope :requested do |loans|
    loans.where(state: 'requested')
  end
  scope :approved do |loans|
    loans.where(state: 'approved')
  end
  scope :rejected do |loans|
    loans.where(state: 'rejected')
  end
  scope :adjusted do |loans|
    loans.where(state: 'adjusted')
  end
  scope :open do |loans|
    loans.where(state: 'open')
  end
  # Index view
  index do
    selectable_column
    id_column
    column :amount
    column :interest_rate
    column :state
    column :user
    column :last_updated_by
    actions
  end

  # Form for editing loans
  form do |f|
    f.inputs "Loan Details" do
      f.input :amount, input_html: { min: 0 }, hint: "Enter the loan amount (minimum 0)"
      f.input :interest_rate, input_html: { min: 0 }, hint: "Enter the interest rate (minimum 0)"
      f.input :state, as: :select, collection: Loan::STATES, hint: "Select the loan state"
      f.input :last_updated_by, as: :select, collection: ["admin"], include_blank: false
    end
    f.actions
  end

  # Show view
  show do
    attributes_table do
      row :amount
      row :interest_rate
      row :state
      row :user
      row :loan_adjustment_amount
      row :loan_adjustment_interest_rate
      row :last_updated_by
    end
  end

  # Custom action items for loan state management
  action_item :approve_loan, only: :show do
    link_to 'Approve Loan', approve_admin_loan_path(loan), method: :put if loan.state == 'requested'
  end

  action_item :reject_loan, only: :show do
    link_to 'Reject Loan', reject_admin_loan_path(loan), method: :put if loan.state == 'requested'
  end

  action_item :accept_loan, only: :show do
    link_to 'Accept Loan', accept_loan_admin_loan_path(loan), method: :put if loan.state == 'approved'
  end

  action_item :reject_loan_by_user, only: :show do
    link_to 'Reject Loan', reject_loan_admin_loan_path(loan), method: :put if loan.state.in?(['approved', 'waiting_for_adjustment_acceptance'])
  end

  action_item :accept_adjustment, only: :show do
    link_to 'Accept Adjustment', accept_adjustment_admin_loan_path(loan), method: :put if loan.state == 'waiting_for_adjustment_acceptance'
  end

  action_item :reject_adjustment, only: :show do
    link_to 'Reject Adjustment', reject_adjustment_admin_loan_path(loan), method: :put if loan.state == 'waiting_for_adjustment_acceptance'
  end

  # Custom member actions for loan management
  member_action :approve, method: :put do
    loan = Loan.find(params[:id])
    if loan.state == 'requested'
      loan.update!(state: 'approved')
      redirect_to admin_loan_path(loan), notice: 'Loan approved successfully!'
    else
      redirect_to admin_loan_path(loan), alert: 'Loan cannot be approved at this stage.'
    end
  end

  member_action :reject, method: :put do
    loan = Loan.find(params[:id])
    if loan.state == 'requested'
      loan.update!(state: 'rejected')
      redirect_to admin_loan_path(loan), notice: 'Loan rejected successfully!'
    else
      redirect_to admin_loan_path(loan), alert: 'Loan cannot be rejected at this stage.'
    end
  end

  member_action :accept_loan, method: :put do
    loan = Loan.find(params[:id])
    if loan.state == 'approved'
      loan.update!(state: 'open')
      # Adjust wallets (replace with actual wallet logic if needed)
      loan.admin.wallet -= loan.amount
      loan.user.wallet += loan.amount
      redirect_to admin_loan_path(loan), notice: 'Loan accepted and moved to open state.'
    else
      redirect_to admin_loan_path(loan), alert: 'Loan cannot be accepted at this stage.'
    end
  end

  member_action :reject_loan, method: :put do
    loan = Loan.find(params[:id])
    if loan.state.in?(['approved', 'waiting_for_adjustment_acceptance'])
      loan.update!(state: 'rejected')
      redirect_to admin_loan_path(loan), notice: 'Loan rejected.'
    else
      redirect_to admin_loan_path(loan), alert: 'Loan cannot be rejected at this stage.'
    end
  end

  member_action :accept_adjustment, method: :put do
    loan = Loan.find(params[:id])
    if loan.state == 'waiting_for_adjustment_acceptance'
      loan.update!(state: 'open')
      # Adjust wallets (replace with actual wallet logic if needed)
      loan.admin.wallet -= loan.amount
      loan.user.wallet += loan.amount
      redirect_to admin_loan_path(loan), notice: 'Adjustment accepted and loan moved to open state.'
    else
      redirect_to admin_loan_path(loan), alert: 'Adjustment cannot be accepted at this stage.'
    end
  end

  member_action :reject_adjustment, method: :put do
    loan = Loan.find(params[:id])
    if loan.state == 'waiting_for_adjustment_acceptance'
      loan.update!(state: 'rejected')
      redirect_to admin_loan_path(loan), notice: 'Adjustment rejected.'
    else
      redirect_to admin_loan_path(loan), alert: 'Adjustment cannot be rejected at this stage.'
    end
  end
end
