module Admin::V1
  class UsersController < ApiController
    def index
      @users = User.all
    end

    def create
      @user = User.new
      @user.attributes = user_params

      save_user!
    end

    private

    def user_params
      return {} unless params.key?(:user)
      params.require(:user).permit(:name, :email, :profile, :password, :password_confirmation)
    end

    def save_user!
      @user.save!
      render :show

    rescue
      render_error(fields: @user.errors.messages)
    end
  end
end