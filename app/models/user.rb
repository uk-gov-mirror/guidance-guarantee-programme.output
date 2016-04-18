# frozen_string_literal: true
class User < ActiveRecord::Base
  devise :database_authenticatable, :confirmable, :invitable, :lockable, :timeoutable, :trackable,
         :validatable, :zxcvbnable, :recoverable

  has_many :appointment_summaries

  scope :admins, -> { where(admin: true).order(:last_name, :first_name) }

  def send_devise_notification(notification, *args)
    devise_mailer.send(notification, self, *args).deliver_later
  end

  def name
    [first_name, last_name].join(' ').strip
  end
end
