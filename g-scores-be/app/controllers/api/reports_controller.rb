class Api::ReportsController < ApplicationController
    def score_distribution
      result = ReportService.new.score_distribution
      render json: result
    end
  end