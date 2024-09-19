class Gcv3 < ApplicationRecord
  self.abstract_class = true

#  connects_to database: { writing: :primary, reading: :gcv3 }
end
