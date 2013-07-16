class RequestUsersController < ApplicationController
  # GET /request_users
  # GET /request_users.json
  def index
    @request_users = RequestUser.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @request_users }
    end
  end

  # GET /request_users/1
  # GET /request_users/1.json
  def show
    @request_user = RequestUser.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @request_user }
    end
  end

  # GET /request_users/new
  # GET /request_users/new.json
  def new
    @request_user = RequestUser.new

    @request_user.request_id = params[:request_id]
    
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @request_user }
    end
  end

  # GET /request_users/1/edit
  def edit
    @request_user = RequestUser.find(params[:id])
  end

  # POST /request_users
  # POST /request_users.json
  def create
    @request_user = RequestUser.new(params[:request_user])

    respond_to do |format|
      if @request_user.save
        format.html { redirect_to @request_user, notice: 'Request user was successfully created.' }
        format.json { render json: @request_user, status: :created, location: @request_user }
      else
        format.html { render action: "new" }
        format.json { render json: @request_user.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /request_users/1
  # PUT /request_users/1.json
  def update
    @request_user = RequestUser.find(params[:id])

    respond_to do |format|
      if @request_user.update_attributes(params[:request_user])
        format.html { redirect_to @request_user, notice: 'Request user was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @request_user.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /request_users/1
  # DELETE /request_users/1.json
  def destroy
    @request_user = RequestUser.find(params[:id])
    @request_user.destroy

    respond_to do |format|
      format.html { redirect_to request_users_url }
      format.json { head :no_content }
    end
  end
end
