module Api
  class ReportsController < ApplicationController
    # GET /api/survivor/report
    def index
      percentageInfected = percentageInfectedOrUninfected('infected')
      percentageUninfected = percentageInfectedOrUninfected('uninfected')
      averageInventoryOfSurvivors = getSurvivorsAverageResources
      totalPointsLostFromInfectedSurvivors = pointsLostFromAllInfectedSurvivor
      render json: { status: 'SUCCESS', message: 'Generated aggregate report', infectionPercentage: percentageInfected, uninfectedPercentage: percentageUninfected, averageInventoryOfSurvivors:, totalPointsLost: totalPointsLostFromInfectedSurvivors },
             status: :ok
    rescue StandardError => e
      render json: { status: 'ERROR', message: 'Could not generate aggregate report' },
             status: :unprocessable_entity
    end

    # GET /api/survivor/report/infectedSurvivors
    def infectedSurvivors
      percentageInfected = percentageInfectedOrUninfected('infected')
      render json: { status: 'SUCCESS', message: 'Successfully evaluated percentage of infected survivors', infectionPercentage: percentageInfected },
             status: :ok
    end

    # GET /api/survivor/report/uninfectedSurvivors
    def uninfectedSurvivors
      percentageUninfected = percentageInfectedOrUninfected('uninfected')
      render json: { status: 'SUCCESS', message: 'Successfully evaluated percentage of uninfected survivors', infectionPercentage: percentageUninfected },
             status: :ok
    end

    # GET /api/reports/averageResources
    def averageResources
      averageInventoryOfSurvivors = getSurvivorsAverageResources
      render json: { status: 'SUCCESS', message: 'Successfully evaluated inventory of remaining survivors', averageResources: averageInventoryOfSurvivors },
             status: :ok
    end

    # GET /api/reports/:id/pointsLostFromSurvivor
    def pointsLostFromSurvivor
      totalPointsLost = pointsLostFromInfectedSurvivor(params[:id])

      if totalPointsLost != false
        render json: { status: 'SUCCESS', message: 'Successfully calculated points lost because of an infected survivor', pointsLost: totalPointsLost },
        status: :ok
      end
    end

    private

    def percentageInfectedOrUninfected(infectedOrUninfected)
      survivorCount = Survivor.count
      survivorInfectionRecord = Survivor.pluck(:infected)

      case infectedOrUninfected

      when 'infected'

        numberOfInfections = survivorInfectionRecord.count(true)
        percentageInfected = (numberOfInfections.to_f / survivorCount.to_f) * 100
        percentageInfected.round(3).to_s.concat(' %')

      when 'uninfected'

        numberOfUninfected = survivorInfectionRecord.count(false)
        percentageUninfected = (numberOfUninfected.to_f / survivorCount.to_f) * 100
        percentageUninfected.round(3).to_s.concat(' %')

      else
        raise 'Invalid option'
      end
    end

    def getSurvivorsAverageResources
      survivorUninfectedCount = Survivor.where(infected: false).count
      totalWater = Survivor.where(infected: false).sum(:water).to_f
      totalSoup = Survivor.where(infected: false).sum(:soup).to_f
      totalFirstAid = Survivor.where(infected: false).sum(:firstAid).to_f
      totalAk47 = Survivor.where(infected: false).sum(:ak47).to_f

      {
        'water' => totalWater / survivorUninfectedCount,
        'soup' => totalSoup / survivorUninfectedCount,
        'firstAid' => totalFirstAid / survivorUninfectedCount,
        'ak47' => totalAk47 / survivorUninfectedCount
      }
    end

    def pointsLostFromInfectedSurvivor(id)
      tradeValues = {
        'water' => 14,
        'soup' => 12,
        'firstAid' => 10,
        'ak47' => 8
      }

      sumPointsLost = 0

      begin
        survivor = Survivor.find(id)
        begin
          if survivor[:infected] == true

            survivorInventory = survivor.slice(:water, :soup, :firstAid, :ak47)

            survivorInventory.values.each_index do |i|
              sumPointsLost += survivorInventory.values[i] * tradeValues.values[i]
            end

            return sumPointsLost
          else
            raise Exception 'Survivor is not infected'
          end
        rescue StandardError => e
          render json: { status: 'ERROR', message: 'Survivor is not infected' },
                 status: :bad_request
          return false
        end
      rescue StandardError => e
        render json: { status: 'ERROR', message: 'Survivor with this Id cannot be found' },
               status: :not_found
        return false
      end
    end

    def pointsLostFromAllInfectedSurvivor
      tradeValues = {
        'water' => 14,
        'soup' => 12,
        'firstAid' => 10,
        'ak47' => 8
      }

      sumPointsLost = 0

      survivors = Survivor.all.where(infected: true)

      totalWater = survivors.sum(:water)
      totalSoup = survivors.sum(:soup)
      totalFirstAid = survivors.sum(:firstAid)
      totalAk47 = survivors.sum(:ak47)

      totalLostInventory = {
        'totalWater' => totalWater,
        'totalSoup' => totalSoup,
        'totalFirstAid' => totalFirstAid,
        'TotalAk47' => totalAk47
      }

      totalLostInventory.values.each_index do |i|
        sumPointsLost += totalLostInventory.values[i] * tradeValues.values[i]
      end

      sumPointsLost
    end
  end
end
