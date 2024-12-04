class CalculateInterestJob < ApplicationJob
  queue_as :default

  def perform(*args)
    Rails.logger.info("$$$$$$$$$$$$$$$$$$$$$$$CalculateInterestJob executed at #{Time.current}$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$")
    Loan.where(state: 'open').find_each do |loan|
      loan.calculate_interest
    end
  end
end
