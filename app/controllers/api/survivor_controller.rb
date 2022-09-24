
class Api::SurvivorController < ApplicationController

    # GET /api/survivor
    def index
        @survivors = Survivor.all
        render json: { status: 'SUCCESS', message: 'List of survivors', data:@survivors}, status: :created
    end

    # POST /api/survivor
    def create
        @survivor = Survivor.new(survivor_params)
        if @survivor.save
            puts 'REMOVE-ME CALLING SURVIVOR CREATE ENDPOINT'
            render json: @survivor
        else
            render error: { error: 'Unable to create a Survivor' }, status: 400
        end
    end

    # PUT /api/survivor/:id/location
    def location
        @survivor = Survivor.find(params[:id])
        if @survivor.update(survivor_location_params)
            render json: { status: 'SUCCESS', message: 'Updated survivor location', name:@survivor[:name] , latitude: @survivor[:latitude], longitude: @survivor[:longitude] }, status: :ok
        else
            render json: { status: 'ERROR', message: "Unable to update Survivor location", data:@survivorLoaction.errors }, status: :unprocessable_entity
        end
    end

    private
    def survivor_params
        params.require(:survivor).permit(:name, :age, :gender, :latitude, :longitude, :water, :soup, :firstAid, :ak47, :infected)
    end
    def survivor_location_params
        params.require(:location).permit(:latitude, :longitude)
    end
end
