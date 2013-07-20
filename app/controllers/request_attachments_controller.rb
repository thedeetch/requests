class RequestAttachmentsController < ApplicationController
  # GET /request_attachments
  # GET /request_attachments.json
  def index
    @request_attachments = RequestAttachment.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @request_attachments }
    end
  end

  # GET /request_attachments/1
  # GET /request_attachments/1.json
  def show
    @request_attachment = RequestAttachment.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @request_attachment }
    end
  end

  # GET /request_attachments/new
  # GET /request_attachments/new.json
  def new
    @request_attachment = RequestAttachment.new

    @request_attachment.request_id = params[:request_id]

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @request_attachment }
    end
  end

  # GET /request_attachments/1/edit
  def edit
    @request_attachment = RequestAttachment.find(params[:id])
  end

  # POST /request_attachments
  # POST /request_attachments.json
  def create
    @request_attachment = RequestAttachment.new(params[:request_attachment])

    respond_to do |format|
      if @request_attachment.save
        format.html { redirect_to @request_attachment.request, notice: 'Request attachment was successfully created.' }
        format.json { render json: @request_attachment, status: :created, location: @request_attachment }
      else
        format.html { render action: "new" }
        format.json { render json: @request_attachment.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /request_attachments/1
  # PUT /request_attachments/1.json
  def update
    @request_attachment = RequestAttachment.find(params[:id])

    respond_to do |format|
      if @request_attachment.update_attributes(params[:request_attachment])
        format.html { redirect_to @request_attachment, notice: 'Request attachment was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @request_attachment.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /request_attachments/1
  # DELETE /request_attachments/1.json
  def destroy
    @request_attachment = RequestAttachment.find(params[:id])
    @request_attachment.destroy

    respond_to do |format|
      format.html { redirect_to request_attachments_url }
      format.json { head :no_content }
    end
  end
end
