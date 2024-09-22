class EntriesController < ApplicationController
  layout "entry_layout", only: [ :index, :show ]

  before_action :set_entry, only: %i[ edit update destroy ]
  before_action :set_category, only: %i[ new edit create update ]
  load_and_authorize_resource

  # GET /entries or /entries.json
  def index
    @entries = Entry.order("created_at DESC").page(params[:page]).per_page(12)
    @search = params[:search]
    @sort = params[:sort]
    @resort = params[:resort]
    if @search.present?
      @search = params.require(:search).permit(:q)
      @q = @search["q"].to_s.html_safe
      # searchkick
      @entries = Entry.search(@q, order: { created_at: :desc },
                                  page: params[:page], per_page: 12)
    end
    if @sort.present? && ["created_at", "heading", "view_count"].include?(@sort) && ["asc", "desc"].include?(@resort) && @search.present?
      @sort = params.require(:sort)
      @resort = params.require(:resort)
      @entries = Entry.search(@search["q"], order: { @sort => @resort },
                                            page: params[:page], per_page: 12)
    elsif @sort.present? && ["created_at", "heading", "view_count"].include?(@sort) && ["asc", "desc"].include?(@resort)
      @sort = params.require(:sort)
      @resort = params.require(:resort)
      @entries = Entry.search("*", order: { @sort => @resort },
                                   page: params[:page], per_page: 12)
    end
  end

  # GET /entries/1 or /entries/1.json
  def show
    @entry = Entry.with_attached_entry_images
      .includes(:profile).includes(:collectors)
      .includes(commontator_thread: :comments)
      .find(params[:id])

    # commontator list of comments
    commontator_thread_show(@entry)
    # searchkick @entry.similar random
    @similars = @entry.similar_entries

    @features = Entry.random_search("fender")

    CheckIpJob.perform_async(@entry.id, request.remote_ip)

    respond_to do |format|
      format.html
    end
  end

  # GET /entries/new
  def new
    @entry = Entry.new
  end

  # GET /entries/1/edit
  def edit
  end

  # POST /entries or /entries.json
  def create
    @entry = Entry.new(entry_params)

    respond_to do |format|
      if @entry.save
        format.html { redirect_to @entry, notice: "Entry was successfully created." }
        format.json { render :show, status: :created, location: @entry }
        @entry.translate_bg_job
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @entry.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /entries/1 or /entries/1.json
  def update
    respond_to do |format|
      if @entry.update(entry_params)
        format.html { redirect_to @entry, notice: "Entry was successfully updated." }
        format.json { render :show, status: :ok, location: @entry }
        @entry.translate_bg_job
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @entry.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /entries/1 or /entries/1.json
  def destroy
    @entry.destroy
    respond_to do |format|
      format.html { redirect_to manages_my_entries_path, notice: "Entry was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_entry
    @entry = Entry.with_attached_entry_images.find(params[:id])
  end

  def set_category
    @category = ["Electric-Solid-Body-Guitar", "Electric-Semi-Hollow-Body-Guitar",
                 "Electric-Hollow-Body-Guitar", "Acoustic-Electric-Guitar",
                 "Dreadnought-Acoustic-Guitar", "Classical-Acoustic-Guitar",
                 "Pedal", "Amplifier", "Parts-Accessories", "Rec-Gear", "Others"]
  end

  # Only allow a list of trusted parameters through.
  def entry_params
    params.require(:entry).permit(
      :heading, :maker, :model, :year, :serial, :madein,
      :sound, :price, :category, :geartype, :guitarbody, :neck, :fboard,
      :peg, :fret, :scale, :pickup, :controlls, :bridge, :finish, :weight,
      :body, :vote_weight, :view_count, entry_images: []
    ).merge(member_id: current_member.id)
  end
end
