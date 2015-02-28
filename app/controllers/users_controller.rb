class UsersController < ApplicationController
  before_action :set_user, only: [:show]

  # GET /users
  # GET /users.json
  def index
    @users = LDAP::User.all.sort_by(&:login)
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

  # POST /users
  # POST /users.json
  def create
    login = user_params[:login]
    first = user_params[:first_name]
    last = user_params[:last_name]
    key = user_params[:key]

    if login.blank? || first.blank? || last.blank? || key.blank?
      render json: {error: "all fields are required"}, status: :unprocessable_entity
    elsif LDAP::User.create(login, first, last, key)
      render json: {success: true, message: "user #{login} created."}, status: :ok
    else
      render json: {error: "failed to create user"}, status: :unprocessable_entity
    end
  rescue => e
    render json: {error: e.message}, status: :unprocessable_entity
  end

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
  rescue => e
    render json: {error: e.message}, status: :unprocessable_entity
  end

  def add_group
    login = params[:login]
    group = params[:group]
    if !login || !group
      render json: {error: "login or group not set"}, status: :unprocessable_entity
    elsif LDAP::User.add_group(login, group)
      render json: {success: true, message: "user #{login} added to group #{group}"}, status: :ok
    else
      render json: {error: "failed to add #{login} to group #{group}"}, status: :unprocessable_entity
    end
  rescue => e
    render json: {error: e.message}, status: :unprocessable_entity
  end

  def remove_group
    login = params[:login]
    group = params[:group]

    if !login || !group
      render json: {error: "login or group not set"}, status: :unprocessable_entity
    elsif LDAP::User.remove_group(login, group)
      render json: {success: true, message: "user #{login} removed from group #{group}"}, status: :ok
    else
      render json: {error: "failed to remove #{login} from group #{group}"}, status: :unprocessable_entity
    end
  rescue => e
    render json: {error: e.message}, status: :unprocessable_entity
  end

  def add_key
    login = params[:login]
    key = params[:key]
    key_name = key.split.last

    if !login || !key
      render json: {error: "login or key not set"}, status: :unprocessable_entity
    elsif LDAP::User.add_key(login, key)
      render json: {success: true, message: "key '#{key_name}' added to user #{login}"}, status: :ok
    else
      render json: {error: "failed to add key to #{login}"}, status: :unprocessable_entity
    end
  rescue => e
    render json: {error: e.message}, status: :unprocessable_entity
  end

  def remove_key
    login = params[:login]
    key = params[:key_name]

    if !login || !key
      render json: {error: "login or key not set"}, status: :unprocessable_entity
    elsif LDAP::User.remove_key(login, key)
      render json: {success: true, message: "key '#{key}' removed from #{login}"}, status: :ok
    else
      render json: {error: "failed to remove key from #{login}"}, status: :unprocessable_entity
    end
  rescue => e
    render json: {error: e.message}, status: :unprocessable_entity
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
