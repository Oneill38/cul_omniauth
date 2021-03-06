module Cul::Omniauth::AuthorizingController
  extend ActiveSupport::Concern

  included do
    devise_group :user, contains: [:user]
  end

  def store_location
    session[:return_to] = "#{request.protocol}#{request.host_with_port}#{request.fullpath}"
  end

  def redirect_back_or_default(default)
    redirect_to(session[:return_to] || default)
    session[:return_to] = nil
  end

  def require_user
    unless current_user
      store_location
      redirect_to_login
      return false
    end
  end

  def require_no_user
    if current_user
      store_location
      flash[:notice] = I18n.t('cul.omniauth.only_guest')
      redirect_to root_url
      return false
    end
  end

  def authorize_action
    if can? :"#{controller_name.to_s}##{params[:action].to_s}", Cul::Omniauth::AbilityProxy.new
      return true
    else
      if current_user
        access_denied
        return false
      end
    end
    store_location
    redirect_to_login
    return false
  end

  def access_denied(url=nil)
      flash[:notice] = I18n.t('cul.omniauth.denied')
    redirect_to url || root_url
    return false
  end

end