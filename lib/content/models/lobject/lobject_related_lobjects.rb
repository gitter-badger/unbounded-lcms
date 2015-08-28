module Content
  module Models
    class LobjectRelatedLobject < ActiveRecord::Base
      belongs_to :lobject
      belongs_to :related_lobject, class_name: 'Content::Models::Lobject', foreign_key: 'related_lobject_id'
    end
  end
end
