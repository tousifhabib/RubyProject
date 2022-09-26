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
            "water" => 14,
            "soup" => 12,
            "firstAid" => 10,
            "ak47" => 8
        }

        buyer = Survivor.find(survivor_trade_params[:buyerId])
        seller = Survivor.find(survivor_trade_params[:sellerId])

        #puts "REMOVE-ME #{survivor_trade_params[:itemsToBuy]}"
        #puts "REMOVE-ME #{tradeValues}"
        #puts "REMOVE ME #{isInfected(buyer[:infected], seller[:infected])}"

        # Check if either the buyer or seller is infected
        if isInfected(buyer[:infected], seller[:infected]) == false
            # Check if buyer and seller has items in their inventory to trade and checks if the number of items to be traded is valid
           if hasItems(buyer, seller, survivor_trade_params[:itemsToBuy], survivor_trade_params[:itemsToSell]) == true
            if 
                validTrade(buyer, seller, survivor_trade_params[:itemsToBuy], survivor_trade_params[:itemsToSell], tradeValues)
            end
           else
            puts "FALSE"
           end

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

        # puts "REMOVE-ME #{buyerItemsToSell}"
        # puts "REMOVE-ME #{sellerItemsToBuy}"
        # puts "REMOVE-ME #{itemsToBuy}"
        # puts "REMOVE-ME #{itemsToSell}"

        # Check if the correct number of items the buyer wants to sell exists in their inventory
        buyerItemsToSell.values.each_index do |i|
            if buyerItemsToSell.values[i] < itemsToSell.values[i]
                # puts "REMOVE-ME FALSCH"
                return false
            end
        end

        # Check if the correct number of items the seller wants to buy exists in their inventory
        sellerItemsToBuy.values.each_index do |i|
            if sellerItemsToBuy.values[i] < itemsToBuy.values[i]
                # puts "REMOVE-ME FALSCH"
                return false
            end
        end

        return true
    end

    def validTrade(buyer, seller, itemsToBuy, itemsToSell, tradeValues)
        buyerItemsToSell = buyer.slice(itemsToSell.keys)
        sellerItemsToBuy = seller.slice(itemsToBuy.keys)

        # Only items that the buyer and seller respectively have will be extracted from the tradeValues hash
        buyerTradeValues = tradeValues.select { |key, value| itemsToSell.include? key }
        sellerTradeValues = tradeValues.select { |key, value| itemsToBuy.include? key }

        # Calculate aggregate points of buyer
        buyerSum = 0
        sellerSum = 0

        # Calculates aggregate points of what the buyer is offering
        buyerTradeValues.values.each_index do |i|
            buyerSum += buyerTradeValues.values[i] * itemsToSell.values[i]
        end

        # Calculates aggregate points of what the seller is offering
        sellerTradeValues.values.each_index do |i|
            sellerSum += sellerTradeValues.values[i] * itemsToBuy.values[i]
        end

        if buyerSum == sellerSum

        else
            return false
        end

        puts "REMOVE-ME #{buyerSum}"
        puts "REMOVE-ME #{sellerSum}"

        puts "REMOVE-ME #{tradeValues}"
        puts "REMOVE-ME buyer trade values#{buyerTradeValues}"
        puts "REMOVE-ME buyer items to sell#{buyerItemsToSell}"
        puts "REMOVE-ME seller trade values#{sellerTradeValues}"
        puts "REMOVE-ME seller itesm to sell#{sellerItemsToBuy}"

    end

end
