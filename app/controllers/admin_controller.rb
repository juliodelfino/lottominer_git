class AdminController < ApplicationController
  def index
  end
  
  def ajax_get_results2
    render json: File.read(File.dirname(__FILE__) + "/../../tmp/lotto_results.json")
  end
  
  def ajax_get_results
    
    exclude_columns = ['created_at', 'updated_at']
    columns = LottoResult.attribute_names - exclude_columns
    result = LottoResult.select(columns)
    
    jsonResult = {
      data: result.map{ |row| row.attributes.map{ |cell, cellval| cellval} }
    }
    render json: jsonResult
  end
  
  def ajax_delete_row
    
    lotto_result = LottoResult.find(params[:id])
    lotto_result.destroy
    render json: true
  end
end
