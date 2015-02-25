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
      format.html { render :edit }
    end
  end

  def disable
    login = params[:login]
    if LDAP::User.disable(login)
      render json: {success: true, message: "login #{login} disabled!"}, status: :ok
    else
      render json: {success: false, error: "could not disable user"}, status: :unprocessable_entity
    end
  end

  def enable
    login = params[:login]
    if LDAP::User.enable(login)
      render json: {success: true, message: "login #{login} enabled!"}, status: :ok
    else
      render json: {success: false, error: "could not enable user"}, status: :unprocessable_entity
    end
  end

  def password
    login = params[:login]
    password = params[:password]
    confirm = params[:confirm]

    if !login
      render json: {error: "login not set"}, status: :unprocessable_entity
    elsif password != confirm
      render json: {error: "passwords do not match"}, status: :unprocessable_entity
    elsif LDAP::User.password(login, password)
      render json: {success: true, message: "password for #{login} changed!"}, status: :ok
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
