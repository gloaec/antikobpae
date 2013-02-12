class Content < ActiveRecord::Base
  belongs_to :document

  attr_accessible :text
end
