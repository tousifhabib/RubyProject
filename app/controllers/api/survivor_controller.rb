# frozen_string_literal: true

module Api
  class SurvivorController < ApplicationController
    # GET /api/survivor
    def index
      @survivors = Survivor.all
      render json: { status: 'SUCCESS', message: 'List of survivors', data: @survivors }, status: :created
    end

    # POST /api/survivor
    def create
      @survivor = Survivor.new(survivor_params)
      if @survivor.save
        render json: @survivor
      else
        render error: { error: 'Unable to create a Survivor' }, status: 400
      end
    end

    # PUT /api/survivor/:id/location
    def location
      @survivor = Survivor.find(params[:id])
      if @survivor.update(survivor_location_params)
        render json: { status: 'SUCCESS', message: 'Updated survivor location', name: @survivor[:name], latitude: @survivor[:latitude], longitude: @survivor[:longitude] },
               status: :ok
      else
        render json: { status: 'ERROR', message: 'Unable to update Survivor location', data: @survivor.errors },
               status: :unprocessable_entity
      end
    end

    # PUT /api/survivor/:id/infected
    def infected
      @survivor = Survivor.find(params[:id])

      numInfections = @survivor[:infectionCount]
      numInfections += 1

      if @survivor.update(infectionCount: numInfections)
        if numInfections >= 5
          @survivor.update(infected: true)
          render json: { status: 'SUCCESS', message: 'Updated survivor infection status, survivor is infected', name: @survivor[:name], infectionCount: @survivor[:infectionCount], infected: @survivor[:infected] },
                 status: :ok
        else
          render json: { status: 'SUCCESS', message: 'Updated survivor infection status, survivor is not infected', name: @survivor[:name], infectionCount: @survivor[:infectionCount], infected: @survivor[:infected] },
                 status: :ok
        end
      else
        render json: { status: 'ERROR', message: 'Unable to update survivor infection status', data: @survivor.errors },
               status: :unprocessable_entity
      end
    end

    # POST /api/survivor/trade
    def trade
      # This hash has the number of points that each item is worth
      tradeValues = {
        'water' => 14,
        'soup' => 12,
        'firstAid' => 10,
        'ak47' => 8
      }

      buyer = Survivor.find(survivor_trade_params[:buyerId])
      seller = Survivor.find(survivor_trade_params[:sellerId])

      # Check if either the buyer or seller is infected
      if isInfected(buyer[:infected], seller[:infected]) == false
        # Check if buyer and seller has items in their inventory to trade and checks if the number of items to be traded is valid
        if hasItems(buyer, seller, survivor_trade_params[:itemsToBuy], survivor_trade_params[:itemsToSell]) == true
          if validTrade(buyer, seller, survivor_trade_params[:itemsToBuy], survivor_trade_params[:itemsToSell], tradeValues) != false
            render json: { status: 'SUCCESS', message: 'Successfull Trade', buyerPoints: @buyerSum, sellerPoints: @sellerSum, buyerInventoryChange: @updatedBuyerInventory.merge(id: buyer[:id]), sellerInventoryChange: @updatedSellerInventory.merge(id: seller[:id]) },
            status: :ok
          end
        else
          puts 'FALSE'
        end

      else
        puts 'IMPLEMENT REJECTION LOGIC'
      end
    end

    private

    def survivor_params
      params.require(:survivor).permit(:name, :age, :gender, :latitude, :longitude, :water, :soup, :firstAid, :ak47,
                                       :infected)
    end

    def survivor_location_params
      params.require(:location).permit(:latitude, :longitude)
    end

    def survivor_trade_params
      params.require(:trade).permit(
        :buyerId,
        :sellerId,
        itemsToBuy: %i[water soup firstAid ak47],
        itemsToSell: %i[water soup firstAid ak47]
      )
    end

    def isInfected(buyerInfectionStatus, sellerInfectionStatus)
      if buyerInfectionStatus == true || sellerInfectionStatus == true
        true
      else
        false
      end
    end

    def hasItems(buyer, seller, itemsToBuy, itemsToSell)
      # Check if buyer has items to sell
      buyerItemsAvailableToSell = buyer.slice(itemsToSell.keys)
      sellerItemsAvailableToBuy = seller.slice(itemsToBuy.keys)

      # Check if the correct number of items the buyer wants to sell exists in their inventory
      buyerItemsAvailableToSell.values.each_index do |i|
        if buyerItemsAvailableToSell.values[i] < itemsToSell.values[i]
          return false
        end
      end

      # Check if the correct number of items the seller wants to buy exists in their inventory
      sellerItemsAvailableToBuy.values.each_index do |i|
        if sellerItemsAvailableToBuy.values[i] < itemsToBuy.values[i]
          return false
        end
      end

      true
    end

    def validTrade(buyer, seller, itemsToBuy, itemsToSell, tradeValues)
      
      # Total items that are available in the buyers and sellers inventory that will be transferred to the opposing party
      buyerItemsAvailableToSell = buyer.slice(itemsToSell.keys)
      sellerItemsAvailableToBuy = seller.slice(itemsToBuy.keys)

      buyerItemsAvailableToBuy = seller.slice(itemsToBuy.keys)
      sellerItemsAvailableToSell = buyer.slice(itemsToSell.keys)

      buyerCurrentInventoryToBuy = buyer.slice(itemsToBuy.keys)
      sellerCurrentInventoryToSell = seller.slice(itemsToSell.keys)

      # Only items that the buyer and seller want to trade have will be extracted from the tradeValues hash
      buyerTradeValues = tradeValues.select { |key, _value| itemsToSell.include? key }
      sellerTradeValues = tradeValues.select { |key, _value| itemsToBuy.include? key }

      # Aggregate points of buyer and seller
      @buyerSum = 0
      @sellerSum = 0

      # Calculates aggregate points of what the buyer is offering
      buyerTradeValues.values.each_index do |i|
        @buyerSum += buyerTradeValues.values[i] * itemsToSell.values[i]
      end

      # Calculates aggregate points of what the seller is offering
      sellerTradeValues.values.each_index do |i|
        @sellerSum += sellerTradeValues.values[i] * itemsToBuy.values[i]
      end

      # If the aggregate points for buyer and seller match, the DB record will be updated
      if @buyerSum == @sellerSum

        # Update inventory

        # Items added to inventory
        updatedBuyerInventoryAdded = Hash[buyerCurrentInventoryToBuy.map { |key, value| [key, value + itemsToBuy[key]] }]
        updatedSellerInventoryAdded = Hash[sellerCurrentInventoryToSell.map { |key, value| [key, value + itemsToSell[key]] }]
        
        # Items removed from inventory
        updatedBuyerInventorySold = Hash[buyerItemsAvailableToSell.map { |key, value| [key, value - itemsToSell[key]] }]
        updatedSellerInventorySold = Hash[sellerItemsAvailableToBuy.map { |key, value| [key, value - itemsToBuy[key]] }]

        # Updated inventory contents
        @updatedBuyerInventory = updatedBuyerInventoryAdded.merge(updatedBuyerInventorySold)
        @updatedSellerInventory = updatedSellerInventoryAdded.merge(updatedSellerInventorySold)

        # Updated DB records
        buyer.update(@updatedBuyerInventory)
        seller.update(@updatedSellerInventory)
      else
        return false
      end
    end
  end
end
