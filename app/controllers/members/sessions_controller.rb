# frozen_string_literal: true

class Members::SessionsController < Devise::SessionsController
  layout "login_layout", only: [:new, :create]
  prepend_before_action :check_captcha, only: [:create]
  # before_action :configure_sign_in_params, only: [:create]

  # GET /resource/sign_in
  # def new
  #   super
  # end

  # POST /resource/sign_in
  # def create
  #   super
  # end

  # DELETE /resource/sign_out
  # def destroy
  #   super
  # end

  private

  def check_captcha
    unless verify_recaptcha(action: 'login')
      self.resource = resource_class.new sign_in_params
      clean_up_passwords(resource)

      respond_with_navigational(resource) do
        flash.discard(:recaptcha_error)
        render :new, layout: 'login_layout'
      end
    end
  end

  # protected

  # If you have extra params to permit, append them to the sanitizer.
  # def configure_sign_in_params
  #   devise_parameter_sanitizer.permit(:sign_in, keys: [:attribute])
  # end
end
