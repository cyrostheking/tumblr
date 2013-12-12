class User < ActiveRecord::Base
  attr_accessible :email, :pwd_hash, :token, :username, :password, :avatar

  validates_presence_of :username, :email
  before_save :legit_email
  validates_uniqueness_of :username, :email

  has_many(
    :posts,
    class_name: "Post",
    foreign_key: :user_id,
    primary_key: :id
  )

  def legit_email
    raise unless self.email && self.email.match(/^.+@.+$/)
  end

  def avatar=(avatar)
    if avatar.nil?
      avatar = Avatar.first(offset: rand(Avatar.count))
    end
    @avatar = avatar
  end

  def self.find_by_credentials!( user )
    @user = User.find_by_email!(user[:email])
    raise unless @user.has_password?(user[:password])

    @user
  end

  def reset_token!
    self.token = generate_token
    self.save! unless self.email.nil?
  end

  def generate_token
    SecureRandom.urlsafe_base64(16)
  end

  def password=(password)
    raise 'Password Cannot Be Blank' if password.nil?
    raise 'Password is too short' if password.length < 6
    self.pwd_hash = BCrypt::Password.create(password)
  end

  def has_password?(password)
    BCrypt::Password.new(self.pwd_hash).is_password?(password)
  end
end
