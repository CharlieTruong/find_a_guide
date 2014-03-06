require_relative '../spec_helper'

describe Tour do
  #Association Testing
  it { should belong_to(:ambassador).class_name('User') }
  it { should have_many(:meetups) }

  #Validation Testing
  it { pending } #should validate_presence_of :ambassador_id }
  it { pending } #should validate_presence_of :longitude }
  it { pending } #should validate_presence_of :latitude }
  it { pending } #should validate_presence_of :description }
end
