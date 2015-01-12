# require 'friendly_id'

module Forem
  class Forum
    include Mongoid::Document
    include Forem::Concerns::Viewable

    # extend FriendlyId
    # friendly_id :name, :use => :slugged

    field :name
    field :title
    field :description
    belongs_to :category,     :class_name => 'Forem::Category'
    has_many :topics,         :class_name => 'Forem::Topic', :dependent => :destroy
    has_many :posts,          :class_name => 'Forem::Post', :dependent => :destroy
    #has_many :views, :through => :topics, :dependent => :destroy
    has_many :moderators,     :class_name => 'Forem::Membership'
    has_many :moderator_groups

    validates :category, :name, :description, :presence => true

    attr_accessible :name,:title,:category_id,  :description, :moderator_ids

    alias_attribute :title, :name

    # Fix for #339
    default_scope order_by(:name => :asc)

    def topics
      Topic.in(id: posts.map(&:topic_id))
    end

    def moderator_groups
      ModeratorGroup.in(id: moderators.map(&:moderator_groups_id))
    end

    def last_post_for(forem_user)
      if forem_user && (forem_user.forem_admin? || moderator?(forem_user))
        posts.last
      else
        last_visible_post(forem_user)
      end
    end

    def last_visible_post(forem_user)
      posts.approved_or_pending_review_for(forem_user).last
    end

    def moderator?(user)
      user && belongs_to_moderator_group(user)
    end

    def to_s
      name
    end

    private

    # could be much cleaner using moderator_ids and user.forem_group_ids
    # but unfortunately it breaks jruby builds
    def belongs_to_moderator_group(user)
      (forem_group_ids_for(user) & get_moderator_ids).any?
    end

    def forem_group_ids_for(user)
      user.forem_groups.map { |u| u.id }
    end

    def get_moderator_ids
      moderators.map { |m| m.id }
    end
  end
end
