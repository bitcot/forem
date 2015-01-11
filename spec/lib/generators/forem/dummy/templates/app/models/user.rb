class User
  include Mongoid::Document
  include Forem::DefaultPermissions
  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable

  field :login
  field :forem_admin, type: Boolean, default: false

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me

  def to_s
    fail # to_s should not be called in tests
  end

  def forem_name
    login
  end

end
