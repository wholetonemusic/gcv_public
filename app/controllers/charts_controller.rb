class ChartsController < ApplicationController
  def index
    case params[:category]
    when "entries_summary_1"
      render json: Entry.group(:maker).count
    when "entries_summary_2"
      render json: Entry.group(:category).count
    end
  end
end
