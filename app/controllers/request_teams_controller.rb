class RequestTeamsController < ApplicationController
  # GET /request_teams
  # GET /request_teams.json
  def index
    @request_teams = RequestTeam.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @request_teams }
    end
  end

  # GET /request_teams/1
  # GET /request_teams/1.json
  def show
    @request_team = RequestTeam.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @request_team }
    end
  end

  # GET /request_teams/new
  # GET /request_teams/new.json
  def new
    @request_team = RequestTeam.new

    @request_team.request_id = params[:request_id]

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @request_team }
    end
  end

  # GET /request_teams/1/edit
  def edit
    @request_team = RequestTeam.find(params[:id])
  end

  # POST /request_teams
  # POST /request_teams.json
  def create
    @request_team = RequestTeam.new(params[:request_team])

    respond_to do |format|
      if @request_team.save
        format.html { redirect_to @request_team.request, notice: 'Request team was successfully created.' }
        format.json { render json: @request_team, status: :created, location: @request_team }
      else
        format.html { render action: "new" }
        format.json { render json: @request_team.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /request_teams/1
  # PUT /request_teams/1.json
  def update
    @request_team = RequestTeam.find(params[:id])

    respond_to do |format|
      if @request_team.update_attributes(params[:request_team])
        format.html { redirect_to @request_team.request, notice: 'Request team was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @request_team.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /request_teams/1
  # DELETE /request_teams/1.json
  def destroy
    @request_team = RequestTeam.find(params[:id])
    @request = @request_team.request
    @request_team.destroy

    respond_to do |format|
      format.html { redirect_to @request }
      format.json { head :no_content }
    end
  end
end
