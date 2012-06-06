class Admin::FiltersController < ApplicationController
  
  #fixme: this is /very/ non-generic
  before_filter :require_perm_global_admin
  
  #fixme: also dependent on paginating_find plugin
  def index
    @filters = DiscussionFilter.all(:order=>'pattern_type, pattern', :page=>{:size=>20, :current=>params[:page]})
  end

  # def show
  #   @filter = DiscussionFilter.find(params[:id])
  # end

  def new
    @filter = DiscussionFilter.new
  end
  
  def create
    @filter = DiscussionFilter.new(params[:filter])
    if @filter.save
      flash[:notice] = 'Filter was successfully created.'
      redirect_to admin_filters_url
    else
      render 'new'
    end
  end

  def edit
    @filter == DiscussionFilter.find(params[:id])
  end
  
  def update
    @filter == DiscussionFilter.find(params[:id])
    if @filter.update_attributes(params[:filter])
      flash[:notice] = 'Filter was successfully updated.'
      redirect_to admin_filters_url
    else
      render 'edit'
    end
  end

  def destroy
    DiscussionFilter.find(params[:id]).destroy
    redirect_to admin_filters_url
  end
  
  
  def block_ip
    if request.xhr?
      @filter = DiscussionFilter.new(:response => 'deny', :pattern=>params[:ip])
      if @filter.save
        render :update do |page| page.alert "IP blocked." end
      else
        render :update do |page| page.alert @filter.errors.full_messages.join(".\n") end
      end
    else
      render :text => "Illegal method call", :status => 400
    end
  end
  
end
