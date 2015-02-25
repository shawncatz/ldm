class UsersController < ApplicationController
  before_action :set_user, only: [:show, :edit, :update, :destroy]

  # GET /users
  # GET /users.json
  def index
    @users = LDAP::User.all
  end

  # GET /users/1
  # GET /users/1.json
  def show
  end

  # # GET /users/new
  # def new
  #   @user = User.new
  # end
  #
  # # GET /users/1/edit
  # def edit
  # end

  # # POST /users
  # # POST /users.json
  # def create
  #   @user = User.new(user_params)
  #
  #   respond_to do |format|
  #     if @user.save
  #       format.html { redirect_to @user, notice: 'User was successfully created.' }
  #       format.json { render :show, status: :created, location: @user }
  #     else
  #       format.html { render :new }
  #       format.json { render json: @user.errors, status: :unprocessable_entity }
  #     end
  #   end
  # end

  # PATCH/PUT /users/1
  # PATCH/PUT /users/1.json
  def update
    respond_to do |format|
      if user_params["password"] == user_params["password_confirmation"]
        if LDAP.bind(@user.login, user_params["current_password"])
          if LDAP::User.password(@user.login, user_params["password"])
            flash.now[:notice] = "changed password"
            format.html { render :edit }
          else
            flash.now[:error] = "couldn't change password"
            format.html { render :edit }
          end
        else
          flash.now[:error] = 'Failed to validate current password'
          format.html { render :edit }
        end
      else
        flash.now[:error] = 'passwords do not match'
        format.html { render :edit }
      end

      # if @user.update(user_params)
      #   format.html { redirect_to @user, notice: 'User was successfully updated.' }
      #   format.json { render :show, status: :ok, location: @user }
      # else
      #   format.html { render :edit }
      #   format.json { render json: @user.errors, status: :unprocessable_entity }
      # end
    end
  end

  def password
    login = params[:login]
    password = params[:password]
    confirm = params[:confirm]

    if password != confirm
      render json: {error: "passwords do not match"}, status: :unprocessable_entity
    elsif LDAP::User.password(login, password)
      render json: {success: true}, status: :ok
    else
      render json: {error: "failed to update password"}, status: :unprocessable_entity
    end
  end

  # # DELETE /users/1
  # # DELETE /users/1.json
  # def destroy
  #   @user.destroy
  #   respond_to do |format|
  #     format.html { redirect_to users_url, notice: 'User was successfully destroyed.' }
  #     format.json { head :no_content }
  #   end
  # end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_user
    @user = LDAP::User.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def user_params
    params[:user]
  end
end
