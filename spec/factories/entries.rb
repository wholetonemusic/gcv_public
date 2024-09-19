FactoryBot.define do
  factory :entry do
    member
    heading { "MyString" }
    maker { "MyString" }
    model { "MyString" }
    year { "MyString" }
    serial { "MyString" }
    madein { "MyString" }
    sound { "MyString" }
    price { "MyString" }
    category { "Electric-Solid-Body-Guitar" }
    geartype { "MyString" }
    guitarbody { "MyString" }
    neck { "MyString" }
    fboard { "MyString" }
    peg { "MyString" }
    fret { "MyString" }
    scale { "MyString" }
    pickup { "MyString" }
    controlls { "MyString" }
    bridge { "MyString" }
    finish { "MyString" }
    body { "MyText" }
    view_count { "" }

    trait :attach_image do
      after(:build) do |entry|
        entry.entry_images.attach(ActiveStorage::Blob.create_and_upload!(
          io: File.open(Rails.root.join("spec", "support", "test_image.jpg"), "rb"),
          filename: "test_image.jpg",
          content_type: "image/jpg",
        ).signed_id)
      end
    end

    trait :reindex do
      after(:create) do |entry, _evaluator|
        entry.reindex(refresh: true)
      end
    end

    trait :skip_validate do
      to_create do |entry|
        entry.save(validate: false)
      end
    end
  end
end
