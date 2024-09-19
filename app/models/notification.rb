class Notification < ApplicationRecord
  include Noticed::Model

  belongs_to :recipient, polymorphic: true
  belongs_to :sender, class_name: 'Profile', foreign_key: :profile_id
end
