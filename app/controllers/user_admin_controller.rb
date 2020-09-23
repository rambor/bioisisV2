class UserAdminController < ApplicationController
  before_action :authenticate_user!

  def index
    @pagy, @users = pagy(User.order(:last_name => :desc).all, items: 30)
    @users_size = @users.size

    authorize! :manage, @users
    respond_to do |format|
      format.html
    end
  end

  def destroy
    permitted = params.permit(:id)
    @user = User.find_by_id(permitted[:id])
    authorize! :manage, @user
    if @user.destroy
      redirect_to :action =>'index'
    end
  end

end
