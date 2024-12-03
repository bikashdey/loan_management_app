class UsersController < ApplicationController
  include JwtAuthentication
  
  before_action  :authenticate_request, except: [:create, :login]

  def create
    @user = User.new(user_params)
    if @user.save
      render json: { message: 'User successfully created', user: @user }, status: :created
    else
      render json: { errors: @user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def login 
    user = User.find_by(email: params[:email])
    if user&.valid_password?(params[:password])
      render json: {message: "login successfully", token: user.generate_jwt}, status: 200
    else
      render json: {message: "login failed"}, status: 401
    end
  end

  # Other actions like show, update, etc. (as defined earlier)
  def show
    return render json: { message: "you are not authorized person" } if params[:id].to_i != @current_user.id 
    render json: @current_user.attributes, status: :ok
  end

  def user_loans
    if params[:state].present?
      loans = case params[:state]
              when 'approved'
                @current_user.loans.approved_loans
              when 'requested'
                @current_user.loans.requested_loans
              when 'open'
                @current_user.loans.open_loans
              else
                return render json: { message: "Invalid state parameter" }, status: 400
              end
    else
      loans = @current_user.loans
    end

    if loans.present?
      render json: { loans: loans.as_json }, status: 200
    else
      render json: { message: "Loans do not exist" }, status: 404
    end
  end


  private

  def user_params
    params.require(:user).permit(:email, :password, :password_confirmation, :wallet, :role)
  end
end
