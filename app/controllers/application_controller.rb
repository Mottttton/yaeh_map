class ApplicationController < ActionController::Base
  before_action :configure_permitted_parameters, if: :devise_controller?

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: %i(name nickname region self_introduction))
    devise_parameter_sanitizer.permit(:account_update, keys: %i(name nickname region self_introduction))
  end

  def after_sign_out_path_for(resource_or_scope)
    new_account_session_path
  end
end
