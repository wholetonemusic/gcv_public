class TranslateJaComment < ApplicationRecord
  belongs_to :commontator_comment, class_name: 'Commontator::Comment',
                                   foreign_key: :commontator_comment_id
end
