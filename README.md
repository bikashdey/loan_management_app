

# Project Name:- Loan Managment App

A brief description of what your project does and its purpose.
Story Points:

	1. The system can have multiple users and one admin.

	2. The admin wallet will start with 10 lakh rupees, and each user wallet will start with 10
	thousand rupees.
	
	3. A loan can have the following states: "requested", "approved", "open", "closed",
	"rejected", "waiting_for_adjustment_acceptance", and "readjustment_requested". The
	initial state of a loan is "requested".
	
	4. Each user can request a loan from the admin by entering the desired loan amount and
	rate of interest. Once the user requests a loan, it will be created with the "requested"
	state.
	
	5. After a loan is requested, the admin can see the loan requests from users and will be
	able to approve, adjust, or reject those requests.
	
	6. Without Loan Adjustment Flow
		6.1. If the admin rejects the loan request, the loan will move to the "rejected" state.
		
		6.2. If the admin approves the loan without making any changes to the requested loan
		amount and interest rate, the loan will move to the "approved" state.
		
		6.3. Once approved, the user can see the confirmation request from the admin.
		
		6.4. If the user confirms the approval, the loan moves to the "open" state, and the loan
		amount is debited from the admin's wallet and credited to the user's wallet.
		
		6.5. If the user rejects the approval, the loan request moves to the "rejected" state.
	
	7. With Loan Adjustment Flow
		7.1. If the admin approves the loan by changing the requested loan amount or interest
		rate, the loan will move to the "waiting_for_adjustment_acceptance" state.
		
		7.2. Once the loan is in the "waiting_for_adjustment_acceptance" state, the user can
		see the adjusted loan amount and interest rate. The user can either accept, reject, or
		request a readjustment.
		
		7.3. If the user rejects the adjustment, the loan moves to the "rejected" state.
		
		7.4. If the user accepts the adjustment, the loan moves to the "open" state.
		
		7.5. If the user disagrees with the adjustment, they can request a readjustment. If a
		readjustment is requested, the loan moves to the "readjustment_requested" state.
		
		7.6. Once a readjustment is requested, the admin can either reject the request or
		make another adjustment.
		
		7.7. If the admin makes another adjustment, the flow will repeat. If the admin rejects
		the readjustment request, the loan will move to the "rejected" state.

	8. Once the loan amount is credited to the user's wallet, interest should be calculated on
		the principal loan amount every 5 minutes.
	
	9. For open loans, the user should be able to see the total loan amount (principal +
	interest) that needs to be repaid.
	
	10. If the user repays the loan, the loan amount (principal + interest) should be debited from
	the user's wallet and credited to the admin's wallet. The loan then moves to the "closed"
	state.
	
	11. When the loan amount (principal + interest) exceeds the user's wallet amount, whatever
	money is in the user's wallet should be debited and credited to the admin's wallet. The
	loan is then considered closed.

## Table of Contents

- Requirements
- Installation
- Configuration
- Database Setup
- Running the Application
- Running Sidekiq

## Requirements

Ensure you have the following installed:

Ruby : 3.1.2 (replace with your version)  
Rails: 7.0.4 (replace with your version)  
Redis: 6.2(for Sidekiq job processing)  
PostgreSQL: 13.0 (or compatible version)  
Bundler: 2.3 (run gem install bundler if not installed)  

## Installation

1. Clone the repository:

   git clone `https://github.com/yourusername/your-repository.git`
   cd your-repository


2. Install dependencies:

   bundle install

## Configuration

1. Environment Variables:  
   Create a config/secrets.yml file (or use Rails credentials if preferred) with the following keys:  
   -DATABASE_UR: Your PostgreSQL database URL  
   -REDIS_UR: Redis connection string (e.g., `redis://localhost:6379/0`)  
   -JWT_SECRE: A secret key for encoding/decoding JWT tokens  

2. Database Configuration:  
   Update config/database.yml with your PostgreSQL credentials if necessary.


## Database Setup

Run the following commands to set up the database:

rails db:create   # Creates the database
rails db:migrate  # Runs migrations
rails db:seed     # Seeds the database (if applicable)


## Running the Application

Start the Rails server:

rails server

The app will be available at `http://localhost:3000`.



## Running Sidekiq

Start the Sidekiq server for background job processing:
redis-server --daemonize yes  #it will run redis in background with occupy the terminal.
bundle exec sidekiq

Ensure Redis is running before starting Sidekiq.


## API Endpoints (Optional)


- Autherization Bearer Token is used in postman 
- after Login you will get the token.

User: 

create: POST http://localhost:3000/users
Show GET http://localhost:3000/users/1
LOGIN POST http://localhost:3000/login
USER LOANS GET http://localhost:3000//users/user_loans

Loans: 

Create POST http://localhost:3000/loans
UPDATE LOAN PATCH http://localhost:3000/loans/2/update_loan
REPAY LOAN PUT http://localhost:3000/loans/6/repay

