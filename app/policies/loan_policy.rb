class LoanPolicy < ApplicationPolicy
  def create?
    user.present? && user.role == 'user'
  end

  #user can accept the loan after admin approved the user request from active admin 
  def accept_loan?
    user.present? && user.role == 'user' && record.user_id == user.id && record.state == 'approved'
  end

  def reject_loan?
    user.present? && user.role == 'user' && record.user_id == user.id && %w[approved waiting_for_adjustment_acceptance].include?(record.state)
  end

  def request_readjustment?
    user.present? && user.role == 'user' && record.user_id == user.id && record.state == 'waiting_for_adjustment_acceptance'
  end

  def accept_adjustment?
    user.present? && user.role == 'user' && record.user_id == user.id && record.state == 'waiting_for_adjustment_acceptance'
  end

  def reject_adjustment?
    user.present? && user.role == 'user' && record.user_id == user.id && record.state == 'waiting_for_adjustment_acceptance'
  end

  def repay?
    user.present? && user.role == 'user' && record.user_id == user.id && record.state == 'open'
  end
end
