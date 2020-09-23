class CommentsController < ApplicationController
  protect_from_forgery except: :new

  def new
    #puts current_user.inspect
    permitted = params.require(:submission).permit(:id)
    permitted.permitted?

    @comment = Comment.new(:submission_id => permitted[:id])
    @comment.user_id = current_user.id

    render :template => "submissions/add_comment.js.erb"

  end


   def create
     #
     @comment = Comment.new(comment_params)
     @submission_id = @comment.submission_id
     if @comment.save
       render :template => "submissions/commented.js.erb"
     else
       #render
     end
   end

  def update
    permitted = params.permit(:id)
    permitted.permitted?
    @comment = Comment.find_by(:id => permitted[:id])
    @comment.update!(comment_params)
    render :template => "comments/update.js.erb"
  end

  def edit
    @comment = Comment.find_by(:id => params[:id])

    render :template => "submissions/add_comment.js.erb"
  end

  def destroy
    permitted = params.permit(:id)

    @comment = Comment.find_by(:id => params[:id])
    @submission_data_directory = Submission.find_by(:id => @comment.submission_id).data_directory
    @remove_id = @comment.id
    if permitted.permitted? && @comment.delete
      render :template => "/comments/remove_comment.js.erb"
    else

    end

  end


  private
  # Use callbacks to share common setup or constraints between actions.
  # Only allow a list of trusted parameters through.
  def comment_params
    params.require(:comment).permit(:submission_id, :user_id, :comment)
    #params.fetch(:submission, {})
  end
end
