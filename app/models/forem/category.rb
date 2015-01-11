require 'friendly_id'

module Forem
  class Category
    include Mongoid::Document
    include Mongoid::Timestamps

    field :name
    has_many :forums, :class_name => 'Forem::Forum'
    extend FriendlyId
    friendly_id :name, :use => :slugged

    has_many :forums
    validates :name, :presence => true
    attr_accessible :name

    def to_s
      name
    end

  end
end
