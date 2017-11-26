class SearchController < ApplicationController
  skip_before_filter :authenticate
  
  def index

  end

  def search_number
    token = params[:q].split('-').map{|x|x.rjust(2, '0')}.sort.join('%')
    @results = LottoResult.where('sorted_numbers LIKE ?', "%#{token}%")
    @results = @results.where('lotto_game_id IN (?)', params[:games]) if !params[:games].empty?
    @results = @results.where('draw_date LIKE (?)', params[:date_exp]) if !params[:date_exp].empty?
    @results = @results.where('winners > 0') if !params[:winners].empty? && params[:winners] == 'true'
    @results = @results.order(draw_date: :desc).limit(20);
    render action: 'number_search_results', layout: false
  end
end
