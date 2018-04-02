class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  before_action :set_locale

  private

  def set_locale
    I18n.locale = if params[:locale].present?
      params[:locale]
    elsif session[:locale].present?
      session[:locale]
    else
      I18n.default_locale
    end
    session[:locale] = I18n.locale
  end
end
