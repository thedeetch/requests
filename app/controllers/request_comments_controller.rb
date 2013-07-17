class RequestCommentsController < ApplicationController
  # GET /request_comments
  # GET /request_comments.json
  def index
    @request_comments = RequestComment.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @request_comments }
    end
  end

  # GET /request_comments/1
  # GET /request_comments/1.json
  def show
    @request_comment = RequestComment.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @request_comment }
    end
  end

  # GET /request_comments/new
  # GET /request_comments/new.json
  def new
    @request_comment = RequestComment.new

    @request_comment.request_id = params[:request_id]

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @request_comment }
    end
  end

  # GET /request_comments/1/edit
  def edit
    @request_comment = RequestComment.find(params[:id])
  end

  # POST /request_comments
  # POST /request_comments.json
  def create
    @request_comment = RequestComment.new(params[:request_comment])

    respond_to do |format|
      if @request_comment.save
        format.html { redirect_to @request_comment.request, notice: 'Request comment was successfully created.' }
        format.json { render json: @request_comment, status: :created, location: @request_comment }
      else
        format.html { render action: "new" }
        format.json { render json: @request_comment.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /request_comments/1
  # PUT /request_comments/1.json
  def update
    @request_comment = RequestComment.find(params[:id])

    respond_to do |format|
      if @request_comment.update_attributes(params[:request_comment])
        format.html { redirect_to @request_comment, notice: 'Request comment was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @request_comment.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /request_comments/1
  # DELETE /request_comments/1.json
  def destroy
    @request_comment = RequestComment.find(params[:id])
    @request_comment.destroy

    respond_to do |format|
      format.html { redirect_to request_comments_url }
      format.json { head :no_content }
    end
  end
end
