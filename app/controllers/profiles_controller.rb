class ProfilesController < ApplicationController
  # cancan authentication
  before_action :set_read_ability_and_profile, only: %i(show show_following show_followers)
  before_action :set_update_ability_and_profile, only: %i(edit update)
  # not use load_and_authorize_resource method
  # because show_following, show_followers method set ability

  # GET /profiles/1 or /profiles/1.json
  def show
    @entries = @profile.member.entries
      .order('created_at desc').page(params[:page]).per_page(7)
    @collections = @profile.member.entry_collections
      .order('created_at desc').page(params[:page]).per_page(7)
  end

  # GET /profiles/1/edit
  def edit
  end

  # POST /profiles or /profiles.json
  # Profile creation callbacks on the model side when creating a member
  # not call translate_ja_profile method because
  # default profile.login is "guest#{member.id}member" (not ja)
  # def create
  #   @profile = Profile.new(profile_params)
  #
  #   respond_to do |format|
  #     if @profile.save
  #       format.html { redirect_to @profile, notice: "Profile was successfully created." }
  #       format.json { render :show, status: :created, location: @profile }
  #     else
  #       format.html { render :new, status: :unprocessable_entity }
  #       format.json { render json: @profile.errors, status: :unprocessable_entity }
  #     end
  #   end
  # end

  # PATCH/PUT /profiles/1 or /profiles/1.json
  def update
    respond_to do |format|
      if @profile.update(profile_params)
        format.html { redirect_to @profile, notice: "Profile was successfully updated." }
        @profile.translate_bg_job
      else
        format.html { render :edit, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /profiles/1 or /profiles/1.json
  # def destroy
  #   @profile.destroy
  #   respond_to do |format|
  #     format.html { redirect_to profiles_url, notice: "Profile was successfully destroyed." }
  #     format.json { head :no_content }
  #   end
  # end

  def show_following
    @follows = @profile.member.followed_at_desc.page(params[:page]).per_page(12)
  end

  def show_followers
    @followers = @profile.member.follower_at_desc.page(params[:page]).per_page(12)
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_profile
    @profile = Profile
      .with_attached_avatar_image
      .with_attached_background_image
      .find(params[:id])
  end

  def set_read_ability_and_profile
    set_profile
    if can? :read, @profile
      @profile
    else
      raise CanCan::AccessDenied
    end
  end

  def set_update_ability_and_profile
    set_profile
    if can? :update, @profile
      @profile
    else
      raise CanCan::AccessDenied
    end
  end

  # Only allow a list of trusted parameters through.
  def profile_params
    params.require(:profile).permit(
      :login,
      :about_me,
      :play_field,
      :favorite_guitarist,
      :favorite_studybook,
      :favorite_band,
      :favorite_album,
      :favorite_video,
      :favorite_song,
      :play_history,
      :band,
      :blog,
      :website,
      :youtube,
      :twitter,
      :style,
      :avatar_image,
      :background_image
    )
      .merge(member_id: current_member.id)
  end
end
