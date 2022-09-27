# frozen_string_literal: true

module Api
  class SurvivorController < ApplicationController
    # GET /api/survivor
    def index
      survivors = Survivor.all
      render json: { status: 'SUCCESS', message: 'List of survivors', data: survivors }, status: :ok
    end

    # GET /api/survivor/:id
    def show
      survivor = Survivor.find(params[:id])
      render json: { status: 'SUCCESS', message: 'Successfully found survivor record', survivor: },
             status: :ok
    rescue StandardError => e
      render json: { status: 'ERROR', message: "Could not find survivor record with id: #{params[:id]}" },
             status: :not_found
    end

    # POST /api/survivor
    def create
      survivor = Survivor.new(survivor_params)
      if survivor.save
        render json: { status: 'SUCCESS', message: 'Successfully created survivor', survivor: },
               status: :created
      else
        render json: { status: 'ERROR', message: 'Input validation failed' }, status: :bad_request
      end
    rescue StandardError => e
      render json: { status: 'ERROR', message: 'Unable to create a Survivor' }, status: :bad_request
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
          # Check if the trade is valid if the number of points are equal
          if validTrade(buyer, seller, survivor_trade_params[:itemsToBuy], survivor_trade_params[:itemsToSell],
                        tradeValues) == true
            render json: { status: 'SUCCESS', message: 'Successful trade', buyerPoints: @buyerSum, sellerPoints: @sellerSum, buyerInventoryChange: @updatedBuyerInventory.merge(id: buyer[:id], name: buyer[:name]), sellerInventoryChange: @updatedSellerInventory.merge(id: seller[:id], name: seller[:name]) },
                   status: :ok
          else
            render json: { status: 'ERROR', message: 'unsuccessful trade because buyer and seller points do not match', buyerPoints: @buyerSum, sellerPoints: @sellerSum },
                   status: :bad_request
          end
        else
          render json: { status: 'ERROR', message: 'Unsuccessful trade because buyer or seller does not have so many items' },
                 status: :bad_request
        end
      else
        render json: { status: 'ERROR', message: 'Unsuccessful trade because buyer or seller is infected and their inventory is locked' },
               status: :bad_request
      end
    end

    private

    def survivor_params
      params.require(:survivor).permit(:name, :age, :gender, :latitude, :longitude, :water, :soup, :firstAid, :ak47)
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
        return false if buyerItemsAvailableToSell.values[i] < itemsToSell.values[i]
      end

      # Check if the correct number of items the seller wants to buy exists in their inventory
      sellerItemsAvailableToBuy.values.each_index do |i|
        return false if sellerItemsAvailableToBuy.values[i] < itemsToBuy.values[i]
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
        if itemsToBuy != itemsToSell
          # Items added to inventory
          updatedBuyerInventoryAdded = Hash[buyerCurrentInventoryToBuy.map do |key, value|
                                              [key, value + itemsToBuy[key]]
                                            end]
          updatedSellerInventoryAdded = Hash[sellerCurrentInventoryToSell.map do |key, value|
                                               [key, value + itemsToSell[key]]
                                             end]

          # Items removed from inventory
          updatedBuyerInventorySold = Hash[buyerItemsAvailableToSell.map do |key, value|
                                             [key, value - itemsToSell[key]]
                                           end]
          updatedSellerInventorySold = Hash[sellerItemsAvailableToBuy.map do |key, value|
                                              [key, value - itemsToBuy[key]]
                                            end]

          # Updated inventory contents
          @updatedBuyerInventory = updatedBuyerInventoryAdded.merge(updatedBuyerInventorySold)
          @updatedSellerInventory = updatedSellerInventoryAdded.merge(updatedSellerInventorySold)

          # Updated DB records
          buyer.update(@updatedBuyerInventory)
          seller.update(@updatedSellerInventory)
          true
        else
          false
        end
      else
        false
      end
    end
  end
end
