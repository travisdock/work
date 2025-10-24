class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy
  has_many :projects, dependent: :destroy
  has_many :tasks, dependent: :destroy

  normalizes :email_address, with: ->(e) { e.strip.downcase }

  validates :email_address,
    presence: true,
    uniqueness: { case_sensitive: false },
    format: { with: URI::MailTo::EMAIL_REGEXP, message: "must be a valid email address" }

  validates :password,
    length: { minimum: 12 },
    if: -> { password.present? && !Rails.env.development? }
end
