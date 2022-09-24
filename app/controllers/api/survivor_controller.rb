class Api::SurvivorController < ApplicationController

    # GET /survivor
    def index
        @survivors = Survivor.all
        render json: @survivors
    end

    # POST /survivor
    def create
        data = json_payload
        puts "REMOVE-ME #{data}"
        @survivor = Survivor.new(survivor_params)
        if @survivor.save
            puts 'REMOVE-ME CALLING SURVIVOR CREATE ENDPOINT'
            render json: @survivor
        else
            render error: { error: 'Unable to create a Survivor' }, status: 400
        end
    end
end
