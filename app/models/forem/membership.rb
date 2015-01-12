module Forem
  class Membership

    include Mongoid::Document
    include Mongoid::Timestamps

    belongs_to :group,    :class_name => 'Forem::Group'
    belongs_to :member,   :class_name => Forem.user_class.to_s

    attr_accessible :member_id, :group_id
  end
end
