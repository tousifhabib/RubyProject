
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
            render json: { status: 'ERROR', message: "Unable to update Survivor location", data:@survivor.errors }, status: :unprocessable_entity
        end
    end

    # PUT /api/survivor/:id/infected
    def infected
        @survivor = Survivor.find(params[:id])
        
        numInfections = @survivor[:infectionCount]
        numInfections += 1

        if @survivor.update(:infectionCount => numInfections)
            if numInfections >= 5
                @survivor.update(:infected => true)
                render json: { status: 'SUCCESS', message: 'Updated survivor infection status, survivor is infected', name:@survivor[:name] , infectionCount: @survivor[:infectionCount], infected: @survivor[:infected] }, status: :ok
            else
                render json: { status: 'SUCCESS', message: 'Updated survivor infection status, survivor is not infected', name:@survivor[:name] , infectionCount: @survivor[:infectionCount], infected: @survivor[:infected] }, status: :ok
            end
        else
            render json: { status: 'ERROR', message: "Unable to update survivor infection status", data:@survivor.errors }, status: :unprocessable_entity
        end
    end

    # POST /api/survivor/trade
    def trade
        buyerId = params[:trade][:buyerId]
        sellerId = params[:trade][:sellerId]

        itemsToBuy = params[:trade][:itemsToBuy]
        itemsToSell = params[:trade][:itemsToSell]

        puts "REMOVE-ME #{itemsToSell}"

    end

    private
    def survivor_params
        params.require(:survivor).permit(:name, :age, :gender, :latitude, :longitude, :water, :soup, :firstAid, :ak47, :infected)
    end
    def survivor_location_params
        params.require(:location).permit(:latitude, :longitude)
    end
end
