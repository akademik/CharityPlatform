class User
  include Mongoid::Document

  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :token_authenticatable,
         :authentication_keys => [:username_email]

  ROLES = %w[user]

  ## Database authenticatable
  field :email,              :type => String
  field :username,           :type => String
  field :encrypted_password, :type => String

  # validates_presence_of :email
  validates_presence_of :username
  # validates_presence_of :encrypted_password

  ## Recoverable
  field :reset_password_token,   :type => String
  field :reset_password_sent_at, :type => Time

  ## Rememberable
  field :remember_created_at, :type => Time

  ## Trackable
  field :sign_in_count,      :type => Integer, :default => 0
  field :current_sign_in_at, :type => Time
  field :last_sign_in_at,    :type => Time
  field :current_sign_in_ip, :type => String
  field :last_sign_in_ip,    :type => String

  ## Token authenticatable
  field :authentication_token, :type => String

  ## Authentication by secret. (It will be created after user signed in)
  field :authentication_secret, :type => String
  field :authentication_secret_expiration, :type => Time

  field :first_name, type: String
  field :last_name, type: String
  field :role, type: String, :default => 'user'
  field :points, type: Double, :default => 0

  attr_accessor :username_email

  attr_accessible :username_email, :username, :email, :password, :password_confirmation, :created_at, :updated_at, :omniauth, :first_name, :last_name, :role

  def fullname
    fullname = "#{first_name} #{last_name}"
    (fullname.size <= 1 || fullname=="change name") ? username : fullname
  end

  def user?; role == 'user'; end

  def generate_authentication_secret!
    self.authentication_secret = rand(36**24).to_s(36)
    self.authentication_secret_expiration = Time.now + Devise.timeout_in
  end

  # function to handle user's username_email via email or username
  def self.find_for_database_authentication(warden_conditions)
    conditions = warden_conditions.dup
    if username_email = conditions.delete(:username_email).downcase
      where(conditions).where('$or' => [ {:username => /^#{Regexp.escape(username_email)}$/i}, {:email => /^#{Regexp.escape(username_email)}$/i} ]).first
    else
      where(conditions).first
    end
  end

end
