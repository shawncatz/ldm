class GroupsController < ApplicationController
  before_action :set_group, only: [:show, :edit, :update, :destroy]

  # GET /groups
  # GET /groups.json
  def index
    @groups = LDAP::Group.all.sort_by(&:name)
  end

  # GET /groups/1
  # GET /groups/1.json
  def show
  end

  # # GET /groups/new
  # def new
  #   @group = Group.new
  # end

  # # GET /groups/1/edit
  # def edit
  # end

  def add_user
    name = group_params[:name]
    user = group_params[:user]

    if !name || !user
      render json: {error: "user or group not set!"}, status: :unprocessable_entity
    elsif LDAP::Group.add_user(name, user)
      render json: {success:true, message: "user #{user} added to group #{name}"}, status: :ok
    end
  rescue => e
    render json: {error: e.message}, status: :unprocessable_entity
  end

  # POST /groups
  # POST /groups.json
  def create
    name = group_params[:name]

    if LDAP::Group.create(name)
      render json: {success: true, message: "group #{name} created."}, status: :ok
    else
      render json: {error: "failed to create group"}, status: :unprocessable_entity
    end
  rescue => e
    render json: {error: e.message}, status: :unprocessable_entity
  end

  # PATCH/PUT /groups/1
  # PATCH/PUT /groups/1.json
  def update
    respond_to do |format|
      if @group.update(group_params)
        format.html { redirect_to @group, notice: 'Group was successfully updated.' }
        format.json { render :show, status: :ok, location: @group }
      else
        format.html { render :edit }
        format.json { render json: @group.errors, status: :unprocessable_entity }
      end
    end
  end

  # # DELETE /groups/1
  # # DELETE /groups/1.json
  # def destroy
  #   @group.destroy
  #   respond_to do |format|
  #     format.html { redirect_to groups_url, notice: 'Group was successfully destroyed.' }
  #     format.json { head :no_content }
  #   end
  # end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_group
      @group = LDAP::Group.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def group_params
      params[:group]
    end
end
