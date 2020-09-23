class ApplicationController < ActionController::Base
  include Pagy::Backend
  before_action :configure_permitted_parameters, if: :devise_controller?

  protected

  def configure_permitted_parameters
    # attr_accessible :email, :password, :password_confirmation, :remember_me, :city, :last_name, :first_name
    devise_parameter_sanitizer.permit(:sign_up, keys: [:email, :city, :last_name, :first_name, :country])
  end

  def signif(number, signs)
    Float("%.#{signs}g" % number)
  end

end
