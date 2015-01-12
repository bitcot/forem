module Forem
  class ModeratorGroup

    include Mongoid::Document
    include Mongoid::Timestamps

    belongs_to :forum, :inverse_of => :moderator_groups
    belongs_to :group

    attr_accessible :group_id
  end
end
