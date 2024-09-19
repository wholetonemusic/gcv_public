# frozen_string_literal: true

# global controller defines
class ApplicationController < ActionController::Base
  before_action :store_user_location!, if: :storable_location?
  around_action :switch_locale

  # skip CanCan auth when Devise auth
  skip_authorization_check if: :devise_controller?

  # when accessdenied by CanCan, redirect to Devise actions
  rescue_from CanCan::AccessDenied do |exception|
    Rails.logger.debug "Access denied on #{exception.action} #{exception.subject.inspect}"
    if current_member.nil?
      session[:next] = request.fullpath
      respond_to do |format|
        format.html { redirect_to new_member_session_path, alert: 'You have to log in to continue.' }
        format.turbo_stream { render turbo_stream: turbo_stream.replace('votes', partial: 'partial/require_login') }
      end
    else
      redirect_back(fallback_location: root_path)
    end
  end

  # instead current_user of CanCan
  def current_user
    current_member
  end

  private

  # Its important that the location is NOT stored if:
  # - The request method is not GET (non idempotent)
  # - The request is handled by a Devise controller such as Devise::SessionsController as that could cause an
  #    infinite redirect loop.
  # - The request is an Ajax request as this can lead to very unexpected behaviour.
  def storable_location?
    request.get? && is_navigational_format? && !devise_controller? && !request.xhr?
  end

  def store_user_location!
    # :member is the scope we are authenticating
    store_location_for(:member, request.fullpath)
  end

  def switch_locale(&action)
    locale = params[:locale] || locale_from_request || extract_locale || I18n.default_locale
    I18n.with_locale(locale, &action)
  end

  def extract_locale(attr = :locale)
    parsed_locale = params[attr]
    I18n.available_locales.map(&:to_s).include?(parsed_locale) ? parsed_locale : nil
  end

  def locale_from_request
    return unless request.headers.key?('HTTP_ACCEPT_LANGUAGE')

    string = request.headers.fetch('HTTP_ACCEPT_LANGUAGE')
    locale = AcceptLanguage.parse(string).match(*I18n.available_locales)
    return if locale.nil?

    locale
  end

  def default_url_options
    { locale: I18n.locale }
  end
end
