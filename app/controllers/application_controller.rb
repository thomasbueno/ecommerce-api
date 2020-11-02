class ApplicationController < ActionController::API
  before_action :configure_permitted_params, if: :devise_controller?
  
  protected
  
  def configure_permitted_params
    devise_parameter_sanitizer.permit
    (:sign_up, keys: [:name, :email, :password, :password_confirmation])
  end
end
