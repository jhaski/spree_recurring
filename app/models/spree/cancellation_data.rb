class Spree::CancellationData < ActiveRecord::Base
  belongs_to :subscription
  attr_accessible :comments, :reasons
end
