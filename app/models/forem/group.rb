module Forem
  class Group

    include Mongoid::Document
    include Mongoid::Timestamps

    field :name,              type: String
    validates :name,          :presence => true

    has_many :memberships,    :class_name => 'Forem::Membership'
    has_many :members,        :class_name => Forem.user_class.to_s

    attr_accessible :name

    def memberships
      Membership.in(id: members.map(&:membership_id))
    end

    def to_s
      name
    end
  end
end
