# frozen_string_literal: true

# randing page and terms page
class MainController < ApplicationController
  layout 'entry_layout'

  def index
    @recommend_entries = Entry.top_rand_entries('Electric-Solid-Body-Guitar', 5)
    @recent_entries = Entry.order(created_at: :desc).limit(10).includes(:profile)

    respond_to do |format|
      format.html
    end
  end

  def about
    respond_to do |format|
      format.html
    end
  end

  def contact
    respond_to do |format|
      format.html
    end
  end

  def services
    respond_to do |format|
      format.html
    end
  end

  def terms
    respond_to do |format|
      format.html
    end
  end

  def policy
    respond_to do |format|
      format.html
    end
  end

  def help
    respond_to do |format|
      format.html
    end
  end
end
