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
        tradeValues = {
            water: 14,
            soup: 12,
            firstAid: 10,
            ak47: 8,
        }

        buyer = Survivor.find(survivor_trade_params[:buyerId])
        seller = Survivor.find(survivor_trade_params[:sellerId])

        #puts "REMOVE-ME #{survivor_trade_params[:itemsToBuy]}"
        #puts "REMOVE-ME #{tradeValues}"
        #puts "REMOVE ME #{isInfected(buyer[:infected], seller[:infected])}"

        if isInfected(buyer[:infected], seller[:infected]) == false
            # Check if buyer and seller has items to trade
            hasItems(buyer, seller, survivor_trade_params[:itemsToBuy], survivor_trade_params[:itemsToSell])

        else
            puts "IMPLEMENT REJECTION LOGIC"
        end

    end

    private
    
    def survivor_params
        params.require(:survivor).permit(:name, :age, :gender, :latitude, :longitude, :water, :soup, :firstAid, :ak47, :infected)
    end
    
    def survivor_location_params
        params.require(:location).permit(:latitude, :longitude)
    end

    def survivor_trade_params
        params.require(:trade).permit(
            :buyerId, 
            :sellerId, 
            itemsToBuy: [:water, :soup, :firstAid, :ak47], 
            itemsToSell: [:water, :soup, :firstAid, :ak47])
    end

    def isInfected(buyerInfectionStatus, sellerInfectionStatus)
        if buyerInfectionStatus == true || sellerInfectionStatus == true
            return true
        else
            return false
        end
    end

    def hasItems(buyer, seller, itemsToBuy, itemsToSell)
        # Check if buyer has items to sell
        buyerItemsToSell = buyer.slice(itemsToSell.keys)
        sellerItemsToBuy = seller.slice(itemsToBuy.keys)

        # if buyer
        #     puts "URGAYHAHA!"
        # end

        puts "REMOVE-ME #{buyerItemsToSell}"
        puts "REMOVE-ME #{sellerItemsToBuy}"
        puts "REMOVE-ME #{buyerItemsToBuy}"
        puts "REMOVE-ME #{sellerItemsToSell}"
    end

end
