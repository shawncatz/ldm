class User < ActiveRecord::Base
  enum role: [:user, :vip, :admin]
  after_initialize :set_default_role, :if => :new_record?

  def set_default_role
    self.role ||= :user
  end

  def disabled?
    entry.disabled?
  end

  def enabled?
    entry.enabled?
  end

  private

  def entry
    LDAP::User.find(self.login)
  end

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  # :validatable
  # :rememberable
  # :recoverable
  # :registerable
  devise :database_authenticatable, :timeoutable, :trackable
end
