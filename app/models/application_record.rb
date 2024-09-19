class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true
  # if Rails.env.test?
  #   connects_to database: { writing: :primary, reading: :gcv3 }
  # end

  # vote_scope: 'collection' == 1
  Vote_collection = 1
  # vote_scope: 'follow' == 2
  Vote_follow = 2
  # vote_scope: 'unfollow' == 3
  Vote_unfollow = 3
  # vote_scope: 'block' == 4
  Vote_block = 4
  # vote_scope: 'favorite' == 5
  Vote_favorite = 5
  # vote_scope: 'like' == 6
  Vote_like = 6
end
