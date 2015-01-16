require 'active_support/concern'

module Forem
  module Concerns
    module Viewable
      extend ActiveSupport::Concern

      included do
        has_many :views, :as => :viewable, :class_name => 'Forem::View'
      end

      def view_for(user)
        views.find_by_user_id(user.id)
      end

      # Track when users last viewed topics
      def register_view_by(user)
        return unless user

        view = views.where(:user_id=> user.id).first_or_create
        view.inc(:count, 1)
        inc(:views_count,1)

        # update current_viewed_at if more than 15 minutes ago
        if view.current_viewed_at.nil?
          view.past_viewed_at = view.current_viewed_at = Time.now
        end

        # Update the current_viewed_at if it is BEFORE 15 minutes ago.
        if view.current_viewed_at < 15.minutes.ago
          view.past_viewed_at    = view.current_viewed_at
          view.current_viewed_at = Time.now
          view.save
        end
      end
    end
  end
end
