class CategoriesController < ApplicationController
  layout "entry_layout"

  def index
    @search = params[:search]
    @category = params[:category]
    @sort = params[:sort]
    @resort = params[:resort]

    if @search.present? && @category.present?
      @search = params.require(:search).permit(:q)
      @category = params.require(:category)
      @q = @search["q"]
      @entries = Entry.search(@q, where: { category: @category.split("-").map(&:capitalize).join("-") },
                                  order: { created_at: :desc }, page: params[:page], per_page: 12)
      if @sort.present? && ["created_at", "heading", "view_count"].include?(@sort) && ["asc", "desc"].include?(@resort) && @category.present?
        @sort = params.require(:sort)
        @resort = params.require(:resort)
        @entries = Entry.search(@q, where: { category: @category.split("-").map(&:capitalize).join("-") }, order: { @sort => @resort },
                                    page: params[:page], per_page: 12)
      end
    else
      @entries = Entry.search(@category, fields: [:category], order: { created_at: :desc }, page: params[:page], per_page: 12)
      if @sort.present? && ["created_at", "heading", "view_count"].include?(@sort) && ["asc", "desc"].include?(@resort) && @category.present?
        @sort = params.require(:sort)
        @resort = params.require(:resort)
        @entries = Entry.search(@category, fields: [:category], order: { @sort => @resort },
                                           page: params[:page], per_page: 12)
      end
    end
    render template: "entries/index"
  end
end
