class ApplicationController < ActionController::Base
  protect_from_forgery
  # Workaround to make cancan work with Rails4
  # https://github.com/ryanb/cancan/issues/835#issuecomment-18663815
  before_filter do
    resource = controller_name.singularize.to_sym
    method = "#{resource}_params"
    params[resource] &&= send(method) if respond_to?(method, true)
  end

  rescue_from CanCan::AccessDenied do |exception|
    redirect_to root_url, :alert => exception.message
  end

  def current_user
    @current_user ||= User.find_by_id!(cookies.signed[:user_id]) if cookies.signed[:user_id]
  end
  helper_method :current_user

  private

  def bypass_captcha_or_not(object)
    object.skip_textcaptcha = (can? :bypass_captcha, current_user) ? true : false
  end

  def rate_user user=current_user, rate_weight
    user.increment! :user_rate, rate_weight
  end

  def record_activity(note)
    @activity = ActivityLog.new
    @activity.user = current_user
    @activity.note = note
    @activity.browser = request.env['HTTP_USER_AGENT']
    @activity.ip_address = request.env['REMOTE_ADDR']
    @activity.controller = controller_name
    @activity.action = action_name
    params.delete(:password)
    params.delete(:authenticity_token)
    @activity.params = params.to_json
    @activity.save
  end

  def share_by_mail
    @share_by_mail = ShareByMail.new(current_user)
    @share_by_mail.textcaptcha
    bypass_captcha_or_not @share_by_mail
  end
end
