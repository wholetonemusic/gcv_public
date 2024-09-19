require "rails_helper"

# before create data to gcv3_test database which insert from gcv3.1.sql file
RSpec.describe "Member, Profile, Entry, type: :model" do
#  before do
#    ActiveRecord::Base.connection.execute("
#        UPDATE gcv3_test.members
#        SET sign_in_count = 0
#        WHERE sign_in_count IS NULL
#                                          ")
#  end
#
#  describe "multiple database access" do
#    before do
#      ActiveRecord::Base.connection.execute("
#          INSERT INTO gcv6_test.members (id, email, legacy_password, 
#            legacy_salt, remember_created_at, sign_in_count, 
#            last_sign_in_at, current_sign_in_ip, last_sign_in_ip, 
#            created_at, updated_at) 
#          SELECT id, email, encrypted_password, 
#            password_salt, remember_created_at, sign_in_count, 
#            last_sign_in_at, current_sign_in_ip, last_sign_in_ip, 
#            created_at, updated_at
#          FROM gcv3_test.members 
#                                            ")
#
#      ActiveRecord::Base.connection.execute("
#          INSERT INTO gcv6_test.profiles (id, member_id,
#            login, about_me, play_field, favorite_guitarist,
#            favorite_studybook, favorite_band, favorite_album,
#            favorite_video, favorite_song, play_history, band, 
#            blog, website, style, created_at, updated_at) 
#          SELECT id, member_id,
#            login, about_me, play_field, favorite_guitarist,
#            favorite_studybook, favorite_band, favorite_album,
#            favorite_video, favorite_song, play_history, band, 
#            blog, website, style, created_at, updated_at
#          FROM gcv3_test.profiles
#                                            ")
#
#      ActiveRecord::Base.connection.execute("
#          INSERT INTO gcv6_test.entries (id, member_id, 
#            heading, maker, model, year, serial, madein,
#            sound, price, category, geartype, guitarbody,
#            neck, fboard, peg, fret, scale, pickup, controlls,
#            bridge, finish, body, created_at, updated_at, view_count) 
#          SELECT id, member_id, 
#            heading, maker, model, year, serial, madein,
#            sound, price, category, geartype, guitarbody,
#            neck, fboard, peg, fret, scale, pickup, controlls,
#            bridge, finish, body, created_at, updated_at, view_count
#          FROM gcv3_test.entries
#                                            ")
#    end
#
#    it 'import members data' do
#      ActiveRecord::Base.connected_to(role: :reading) do
#        @member3 = Member.find 1
#      end
#
#      ActiveRecord::Base.connected_to(role: :writing) do
#        @member6 = Member.find 1
#      end
#
#      expect(@member6.legacy_password).to eq @member3.encrypted_password
#    end
#
#    it "import profiles data" do
#      ActiveRecord::Base.connected_to(role: :reading) do
#        @profile3 = Profile.find 1
#      end
#
#      ActiveRecord::Base.connected_to(role: :writing) do
#        @profile6 = Profile.find 1
#      end
#
#      expect(@profile6.login).to eq @profile3.login
#    end
#
#    it "import profiles data" do
#      ActiveRecord::Base.connected_to(role: :reading) do
#        @entry3 = Entry.find 9
#      end
#
#      ActiveRecord::Base.connected_to(role: :writing) do
#        @entry6 = Entry.find 9
#      end
#
#      expect(@entry6.heading).to eq @entry3.heading
#    end
#
#    it "import registerd but not have profile member's profile data" do
#      member = Member.select("id","last_sign_in_at").map {|m| m.id}
#      profile = Profile.select("member_id").map {|p| p.member_id}
#      diff_id = member - profile
#
#      ActiveRecord::Base.connection.execute("
#           INSERT INTO gcv6_test.profiles (member_id, login, created_at, updated_at)
#           SELECT id, login, created_at, updated_at
#           FROM gcv3_test.members
#           WHERE id IN (#{diff_id.join(', ')})
#                                            ")
#
#      login = ActiveRecord::Base.connection.execute("
#            SELECT login FROM gcv3_test.members WHERE id=3
#                                                    ")
#
#      expect(Profile.find_by_member_id(3).login).to eq login.first[0].to_s
#    end
#
#    it 'import vote data' do
#      follows = ActiveRecord::Base.connection.select_all('
#           SELECT entry_id, member_id, created_at
#           FROM gcv3_test.follows
#                                                         ').to_a
#
#                                                         follows.each do |f|
#                                                           entry = Entry.find(f['entry_id'])
#                                                           member = Member.find(f['member_id'])
#                                                           votes = entry.collector_votes.
#                                                             new(member: member, votable: entry, vote_scope: 1,
#                                                                 created_at: f['created_at'])
#                                                           if votes.save
#                                                             Entry.update_counters(entry.id, collector_count: 1)
#                                                           end
#                                                         end
#
#                                                         @f = follows.first
#                                                         ActiveRecord::Base.connected_to(role: :writing) do
#                                                           @entry = Entry.find(@f['entry_id'])
#                                                           @member = Member.find(@f['member_id'])
#                                                         end
#                                                         expect(@entry.collectors.find(@f['member_id'])).to eq @member
#    end
#
#    it 'upload image by active storage' do
#      # image_format = 'application/octet-stream' or 'image/jpg..etc' or 'jpg..etc'
#      image = ActiveRecord::Base.connection.select_all("
#          SELECT id, image_data, image_format, attachable_type, attachable_id
#          FROM gcv3_development.attachment_images
#          WHERE image_format='application/octet-stream'
#          LIMIT 1").to_a
#
#          image.each do |i|
#            data = MiniMagick::Image.read(i['image_data'])
#            if i['image_format'].include?('image/')
#              iformat = i['image_format'].split('/')[1]
#            elsif i['image_format'].include?('application/octet-stream')
#              iformat = 'jpg'
#            else
#              iformat = i['image_format']
#            end
#            data.format(iformat)
#            impfile = Rails.root.join("tmp", "storage", "attach#{i['id']}" +
#                                      "#{i['attachable_type'].downcase}" + "#{i['attachable_id']}" +
#                                      ".#{iformat}")
#            data.write(impfile)
#
#            ActiveRecord::Base.connected_to(role: :writing) do
#              @inattach = i['attachable_type'].constantize.find(i['attachable_id'].to_i)
#            end
#
#            if i['attachable_type'] == 'Entry'
#              inattach = @inattach.entry_images
#            elsif i['attachable_type'] == 'Profile'
#              inattach = @inattach.avatar_image
#            end
#            inattach.attach(ActiveStorage::Blob.create_and_upload!(
#              io: File.open(impfile, 'rb'),
#              filename: "attach#{i['id']}" +
#              "#{i['attachable_type'].downcase}" + "#{i['attachable_id']}" +
#              ".#{iformat}",
#              content_type: "image/#{iformat}"
#            ))
#          end
#          expect(Entry.first.entry_images).not_to be_nil
#    end
#
#    it 'import entry comments' do
#      comments = ActiveRecord::Base.connection.select_all('
#          SELECT * FROM gcv3_test.comments'
#                                                         ).to_a
#
#                                                         comments.each do |c|
#                                                           @member = Member.find(c['member_id'].to_i)
#                                                           @commontable = Entry.find(c['entry_id'].to_i)
#                                                           @thread = @commontable.commontator_thread
#
#                                                           comment = Commontator::Comment.new
#                                                           comment.thread = @thread
#                                                           comment.creator = @member
#                                                           comment.body = c['comment']
#                                                           comment.created_at = c['created_at']
#                                                           comment.updated_at = c['updated_at']
#                                                           comment.save!
#                                                         end
#                                                         expect(Commontator::Comment.first).not_to be_nil
#    end
#
#    it "change entry category value ja to en" do
#      category_data = [
#        ["その他", "Others"],
#        ["アクセサリーその他", "Parts-Accessories"],
#        ["アコースティック - エレアコ", "Acoustic-Electric-Guitar"],
#        ["アコースティック - エレガット", "Acoustic-Electric-Guitar"],
#        ["アコースティック - クラシック", "Classical-Acoustic-Guitar"],
#        ["アコースティック - フラットトップ", "Dreadnought-Acoustic-Guitar"],
#        ["アンプ", "Amplifier"],
#        ["エフェクター", "Pedal"],
#        ["エレクトリック - セミアコ", "Electric-Semi-Hollow-Body-Guitar"],
#        ["エレクトリック - ソリッド", "Electric-Solid-Body-Guitar"],
#        ["エレクトリック - フルアコ", "Electric-Hollow-Body-Guitar"],
#        ["ＤＴＭ", "Rec-Gear"],
#      ]
#      category_data.each do |c|
#        Entry.where(category: c[0]).update_all(category: c[1])
#      end
#      expect(Entry.select(:category).group(:category).map { |o| o.category }).to include("Amplifier")
#    end
#  end
end
