module Admin
  class PhotosController < ApplicationController
    before_action :set_conference
    before_action :set_photo, only: [:edit, :update, :destroy]

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

# Use callbacks to share common setup or constraints between actions.
    def set_conference
      @conference = Conference.find_by(short_title: params[:conference_id])
    end

# Use callbacks to share common setup or constraints between actions.
    def set_photo
      @photo = Photo.find_by(id: params[:id])
    end

# Only allow a trusted parameter "white list" through.
    def photo_params
      params[:photo]
    end
  end
end

