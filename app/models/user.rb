class User < ApplicationRecord
  has_secure_password

  has_many :projects, dependent: :destroy
  has_many :tasks, dependent: :destroy

  validates :email_address, presence: true, uniqueness: { case_sensitive: false }
  validates :email_address, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :password, length: { minimum: 8 }, if: -> { new_record? || !password.nil? }

  normalizes :email_address, with: -> { _1.strip.downcase }
end
