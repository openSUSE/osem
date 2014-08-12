module Admin
  class PhotosController < ApplicationController
    load_and_authorize_resource :conference, find_by: :short_title
    load_and_authorize_resource through: :conference

# GET /admin/photos
    def index
      @photos = @conference.photos.all
    end

# GET /admin/photos/new
    def new
      @photo = @conference.photos.build
    end

# GET /admin/photos/1/edit
    def edit
    end

# POST /admin/photos
    def create
      @photo = @conference.photos.build(photo_params)
      if @photo.save
        redirect_to admin_conference_photos_path, notice: 'Photo was successfully created.'
      else
        flash[:alert] = "A error prohibited this Photo from being saved: #{@photo.errors.full_messages.join('. ')}."
        render :new
      end
    end

# PATCH/PUT /admin/photos/1
    def update
      if @photo.update(photo_params)
        redirect_to admin_conference_photos_path, notice: 'Photo was successfully updated.'
      else
        flash[:alert] = "A error prohibited this Photo from being saved: #{@photo.errors.full_messages.join('. ')}."
        render :edit
      end
    end

# DELETE /admin/photos/1
    def destroy
      @photo.destroy
      redirect_to admin_conference_photos_path, notice: 'Photo was successfully destroyed.'
    end

    private
# Only allow a trusted parameter "white list" through.
    def photo_params
      params[:photo]
    end
  end
end

