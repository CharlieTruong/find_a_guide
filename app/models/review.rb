class Review < ActiveRecord::Base
	belongs_to :reviewer, class_name: "User"
	belongs_to :reviewee, class_name: "User"
	belongs_to :meetup

	validates :rating, :comment, :reviewer_id, :reviewee_id, presence: true
  validates_inclusion_of :rating, in: (0..5)

end
