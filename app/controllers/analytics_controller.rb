class AnalyticsController < ApplicationController
  
  def game
    @totalDrawCount = LottoResult.where(game: params[:id]).count
    @totalDrawsWon = LottoResult.where("game = ? AND winners > 0", params[:id]).count
    @winPercent = @totalDrawsWon.to_f / @totalDrawCount.to_f * 100
    @drawEarliest = LottoResult.where(game: params[:id]).order(:draw_date).limit(1).pluck(:draw_date)[0].strftime("%a, %B %d, %Y")
    @drawLatest = LottoResult.where(game: params[:id]).order(draw_date: :desc).limit(1).pluck(:draw_date)[0].strftime("%a, %B %d, %Y")
  end
  
end
