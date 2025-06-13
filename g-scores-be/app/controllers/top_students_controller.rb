class Api::TopStudentsController < ApplicationController
    def block_a
      result = TopStudentsService.new.block_a
      render json: result
    end
  end