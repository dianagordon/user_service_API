class UsersController < ApplicationController
  skip_before_action :verify_authenticity_token

  def index
    render json: json_data(User.all)
  end

  def new
    user = User.new
  end

  def create
    user = User.new(user_params)

    if user.save
      render json: json_data(user)
    else
      render json: {errors: user.errors}, status: :unprocessable_entity
    end
  end

  def show
    if (user = User.find_by_id(params[:id])).present?
      render json: json_data(user)
    else
      render json: {}, status: :not_found
    end
  end

  def sign_in
    user = User.find_by(email: params[:email])
    if user && user.authenticate(params[:password])
      generated_token = SecureRandom.urlsafe_base64
      user.update(token_digest: generated_token)
      cookies[:token] = generated_token.to_s
      render json: json_data(user)
    else
      render json: {errors: user.errors}
    end
  end

  def sign_out
    user = User.find_by(token_digest: cookies[:token])
    if user
      cookies.delete :token
      render json: json_data(user)
    else
      render json: {}, status: :not_found
    end
  end

  def update
    user = User.find_by_id(params[:id])
    if user && (user.token_digest.to_s == cookies[:token].to_s)
      user.update(update_params)
      render json: json_data(user)
    else
      render json:{}, status: :unauthorized
    end
  end

  private

  def update_params
    params.permit(:id, :first_name, :last_name, :email, :password)
  end

  def user_params
    params.require(:user).permit(:first_name, :last_name, :email, :password)
  end

  def json_data(data)
    return data.to_json(:except => [:created_at, :updated_at, :password_digest, :token_digest])
  end
end
