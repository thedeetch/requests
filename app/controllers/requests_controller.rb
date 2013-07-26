class RequestsController < ApplicationController
  # GET /requests
  # GET /requests.json
  def index
    @query = params[:q]

    if @query
      r = Request.arel_table
      c = RequestComment.arel_table

      @search = Request.joins(:request_comments).
      where(
        r[:id].eq(@query).
        or(r[:title].matches("%#{@query}%")).
        or(r[:description].matches("%#{@query}%")).
        or(c[:text].matches("%#{@query}%"))
      ).uniq
    else
      @requests = Request.all
      @me = Request.where(user_id: 'd370547')
      @unassigned = Request.joins(:request_teams).joins(:teams).where("teams.name = 'DMG_DBA'").uniq
      @open = Request.where(status: 'Open')
      @project = Request.where(context: 'Project')
      @operation = Request.where(status: 'Operations')
    end

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @requests }
    end
  end

  # GET /requests/1
  # GET /requests/1.json
  def show
    @request = Request.find(params[:id])

    @request_comment = RequestComment.new
    @request_comment.request_id = @request.id

    @request_team = RequestTeam.new
    @request_team.request_id = @request.id

    @request_user = RequestUser.new
    @request_user.request_id = @request.id

    @request_attachment = RequestAttachment.new
    @request_attachment.request_id = @request.id

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @request }
    end
  end

  # GET /requests/new
  # GET /requests/new.json
  def new
    @request = Request.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @request }
    end
  end

  # GET /requests/1/edit
  def edit
    @request = Request.find(params[:id])
  end

  # POST /requests
  # POST /requests.json
  def create
    @request = Request.new(params[:request])

    respond_to do |format|
      if @request.save

        #send email
        RequestMailer.new_request(@request).deliver

        format.html { redirect_to @request, notice: 'Request was successfully created.' }
        format.json { render json: @request, status: :created, location: @request }
      else
        format.html { render action: "new" }
        format.json { render json: @request.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /requests/1
  # PUT /requests/1.json
  def update
    @request = Request.find(params[:id])


    respond_to do |format|
      if @request.update_attributes(params[:request])

        #send email
        RequestMailer.update_request(@request).deliver

        format.html { redirect_to @request, notice: 'Request was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @request.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /requests/1
  # DELETE /requests/1.json
  def destroy
    @request = Request.find(params[:id])
    @request.destroy

    respond_to do |format|
      format.html { redirect_to requests_url }
      format.json { head :no_content }
    end
  end
end
