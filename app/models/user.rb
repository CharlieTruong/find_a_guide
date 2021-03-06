class User < ActiveRecord::Base
	# has_one :authentication, dependent: :destroy

	has_many :users_specialties
	has_many :specialties, through: :users_specialties

	has_many :languages_spoken
	has_many :languages, through: :languages_spoken

  has_many :visitor_reviews, through: :visitor_meetups, source: :reviews
  has_many :ambassador_reviews, through: :ambassador_meetups, source: :reviews

	has_many :reviews_given, class_name: "Review", foreign_key: "reviewer_id"
	has_many :reviews_received, class_name: "Review", foreign_key: "reviewee_id", dependent: :destroy

	has_many :tours, class_name: "Tour", foreign_key: "ambassador_id", dependent: :destroy

	has_many :ambassador_meetups, class_name: "Meetup", foreign_key: "ambassador_id", dependent: :destroy
	has_many :visitor_meetups, class_name: "Meetup", foreign_key: "visitor_id"

	validates :first_name, :last_name, :email, presence: true
  validates :email, :uid, uniqueness: true

  after_create :create_alias_email
  before_create :set_default_availability

	def name
 		"#{first_name} #{last_name}"
	end

  def open_information
    [email,phone,gender,age]
  end

  def has_specialty?(specialty)
    self.specialties.any? {|s| s == specialty}
  end

  def empty_reviews(type)
    if type == :visitor
      self.visitor_meetups.where('date_time < ?', Time.now).order('date_time').reverse - self.visitor_reviews.map{|r| r.meetup}
    else
      self.ambassador_meetups.where('date_time < ?', Time.now).order('date_time').reverse - self.ambassador_reviews.map{|r| r.meetup}
    end
  end

  def incomplete_information
    possible_incomplete_attributes = ['tagline','bio','email','phone','gender','age']
    hash = self.attributes.select{|k,v| v.nil? && possible_incomplete_attributes.include?(k)}.keys
  end

  def safe_tagline
    if tagline.nil?
      ""
    else
      tagline
    end
  end

  def average_rating(type)
    ratings = all_ratings(type)
    if ratings.empty?
      return 'No ratings'
    else
      (ratings.order('created_at').map{|r| r.rating.to_i}.reduce(:+) / ratings.count.to_f).round(2)
    end
  end

  def all_ratings(type) #specify ambassador ratings
    reviews_received.where('reviewee_id = ?', id).order('created_at')
  end

  def find_meetup(reviewee)
    @user_meetups = Meetup.where('ambassador_id = ? OR visitor_id = ?', id, id)
    @meetup = @user_meetups.select{|m| m.reviews.all && (m.ambassador_id == reviewee.id || m.visitor.id == reviewee.id)}.first
  end

  def self.from_omniauth(auth)
    where(auth.slice(:provider, :uid)).first_or_initialize.tap do |user|
      user.provider = auth.provider
      user.uid = auth.uid
      user.oauth_token = auth.credentials.token
      user.oauth_expires_at = Time.at(auth.credentials.expires_at)

      user.first_name = auth.info.first_name
      user.last_name = auth.info.last_name
      user.email = user.email ||= auth.extra.raw_info.email

      user.profile_pic = user.profile_pic ||= "http://graph.facebook.com/#{auth.extra.raw_info.id}/picture?type=large"

      user.username = auth.extra.raw_info.username
      user.save!
    end
  end

  def rusty?
    tours.size < 1 || Time.now - tours.last.created_at > 3.month
  end

  private

  def create_alias_email
    self.anonymous_email = 'user' + self.id.to_s + Time.now.to_i.to_s + '@sandbox57336.mailgun.org'
    self.save
  end

  def set_default_availability
    self.ambassador_availability = true;
  end
end

