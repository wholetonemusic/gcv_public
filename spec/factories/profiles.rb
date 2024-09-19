FactoryBot.define do
  factory :profile do
    member
    login { "guest" }
    about_me { "" }
    play_field { "" }
    favorite_guitarist { "" }
    favorite_studybook { "" }
    favorite_band { "" }
    favorite_album { "" }
    favorite_video { "" }
    favorite_song { "" }
    play_history { "" }
    band { "" }
    blog { "" }
    website { "" }
    youtube { "" }
    twitter { "" }
    style { "" }

    trait :attach_image do
      after(:build) do |profile|
        profile.avatar_image.attach(ActiveStorage::Blob.create_and_upload!(
          io: File.open(Rails.root.join("spec", "support", "test_image.jpg"), "rb"),
          filename: "test_image.jpg",
          content_type: "image/jpg",
        ).signed_id)
      end
    end
    
    trait :skip_validate do
      to_create do |profile|
        profile.save(validate: false)
      end
    end
  end
end
