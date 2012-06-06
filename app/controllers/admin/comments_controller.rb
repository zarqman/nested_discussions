class Admin::CommentsController < ApplicationController
  
  #fixme: this is /very/ non-generic
  before_filter :require_perm_global_admin
  
  
  def approve
    @comment = Comment.find(params[:id])
    if @comment.update_attribute(:approval_state, 2)
      render :update do |page|
        page.replace("comment_#{@comment.id}", :partial => 'comments/comment', :locals=>{:c=>@comment, :is_closed=>!@comment.discussion.open?, :is_admin=>true})
        page.alert "Comment approved."
      end
    else
      render :update do |page| page.alert @comment.errors.full_messages.join(".\n") end
    end
  end
  
  def disapprove
    @comment = Comment.find(params[:id])
    if @comment.update_attribute(:approval_state, -1)
      render :update do |page|
        page.replace("comment_#{@comment.id}", :partial => 'comments/comment', :locals=>{:c=>@comment, :is_closed=>!@comment.discussion.open?, :is_admin=>true})
        page.alert "Comment disapproved."
      end
    else
      render :update do |page| page.alert @comment.errors.full_messages.join(".\n") end
    end
  end
  
  def destroy
    @comment = Comment.find(params[:id])
    if @comment.update_attribute(:approval_state, -2)
      render :update do |page|
        page.remove("comment_#{@comment.id}")
        page.alert "Comment deleted."
      end
    else
      render :update do |page| page.alert @comment.errors.full_messages.join(".\n") end
    end
  end
  
end
