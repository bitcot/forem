# require 'friendly_id'

module Forem
  class Topic
    include Mongoid::Document
    include Mongoid::Timestamps

    include Forem::Concerns::Viewable
    include Forem::Concerns::NilUser
    include Workflow

    workflow_column :state
    workflow do
      state :pending_review do
        event :spam,    :transitions_to => :spam
        event :approve, :transitions_to => :approved
      end
      state :spam
      state :approved do
        event :approve, :transitions_to => :approved
      end
    end

    attr_accessor :moderation_option

    # extend FriendlyId
    # friendly_id :subject, :use => :slugged

    attr_accessible :subject, :posts_attributes
    attr_accessible :subject, :posts_attributes, :pinned, :locked, :hidden, :forum_id, :as => :admin

    field :subject
    field :locked, type: Boolean, default: false
    field :pinned, type: Boolean, default: false
    field :hidden, type: Boolean, default: false
    field :last_post_at,          type: Time
    field :views_count

    belongs_to :forum, :class_name => 'Forem::Forum'
    belongs_to :forem_user, :class_name => Forem.user_class.to_s, :foreign_key => :user_id
    embeds_many :subscriptions, :class_name => 'Forem::Subscription'
    has_many   :posts, :dependent => :destroy, :order => "forem_posts.created_at ASC", :class_name => 'Forem::Post'

    # embeds_many :views, :class_name => 'Forem::View'
    accepts_nested_attributes_for :posts

    validates :subject, :presence => true
    validates :user, :presence => true

    before_save  :set_first_post_user
    after_create :subscribe_poster
    after_create :skip_pending_review, :unless => :moderated?

    class << self
      def visible
        where(:hidden => false)
      end

      def by_pinned
        order_by('forem_topics.pinned' => 'DESC',
                 'forem_topics.id' => "ASC")
      end

      def by_most_recent_post
        order_by('forem_topics.last_post_at'=>'DESC','forem_topics.id'=>'ASC')
      end

      def by_pinned_or_most_recent_post
        order_by('forem_topics.pinned' => 'DESC',
                 'forem_topics.last_post_at' => 'DESC','forem_topics.id'=>'ASC')
      end

      def pending_review
        where(:state => 'pending_review')
      end

      def approved
        where(:state => 'approved')
      end

      def approved_or_pending_review_for(user)
        if user
          where :or => [ {'forem_topics.state' => 'approved'}, {'forem_topics.state' =>'pending_review', 'forem_topics.user_id'=> user.id} ]
        else
          approved
        end
      end
    end

    def to_s
      subject
    end

    # Cannot use method name lock! because it's reserved by AR::Base
    def lock_topic!
      update_attributes(:locked, true)
    end

    def unlock_topic!
      update_attributes(:locked, false)
    end

    # Provide convenience methods for pinning, unpinning a topic
    def pin!
      update_attributes(:pinned, true)
    end

    def unpin!
      update_attributes(:pinned, false)
    end

    def moderate!(option)
      send("#{option}!")
    end

    # A Topic cannot be replied to if it's locked.
    def can_be_replied_to?
      !locked?
    end

    def subscribe_poster
      subscribe_user(user_id)
    end

    def subscribe_user(subscriber_id)
      if subscriber_id && !subscriber?(subscriber_id)
        subscriptions.create!(:subscriber_id => subscriber_id)
      end
    end

    def unsubscribe_user(subscriber_id)
      subscriptions_for(subscriber_id).destroy_all
    end

    def subscriber?(subscriber_id)
      subscriptions_for(subscriber_id).any?
    end

    def subscription_for(subscriber_id)
      subscriptions_for(subscriber_id).first
    end

    def subscriptions_for(subscriber_id)
      subscriptions.where(:subscriber_id => subscriber_id)
    end

    def last_page
      (self.posts.count.to_f / Forem.per_page.to_f).ceil
    end

    protected
    def set_first_post_user
      post = posts.first
      post.user = user
    end

    def skip_pending_review
      update_attribute(:state, 'approved')
    end

    def approve
      first_post = posts.by_created_at.first
      first_post.approve! unless first_post.approved?
    end

    def moderated?
      user.forem_moderate_posts?
    end
  end
end
