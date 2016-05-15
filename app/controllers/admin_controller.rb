class AdminController < ApplicationController
  
  def index
    @selected_table = params[:table].nil? ? 'LottoResult' : params[:table]
  end
  
  def ajax_get_results2
    render json: File.read(File.dirname(__FILE__) + "/../../tmp/lotto_results.json")
  end
  
  def ajax_get_results
    
    @selected_table = params[:table].nil? ? 'LottoResult' : params[:table]
    exclude_columns = ['created_at', 'updated_at']
    
    clazz = @selected_table.constantize
    
    columns = clazz.attribute_names - exclude_columns
    result = clazz.select(columns)
    
    jsonResult = {
      data: result.map{ |row| row.attributes.map{ |cell, cellval| cellval} }
    }
    render json: jsonResult
  end
  
  def ajax_delete_row
    
    @selected_table = params[:table].nil? ? 'LottoResult' : params[:table]
    clazz = @selected_table.constantize
    lotto_result = clazz.find(params[:id])
    lotto_result.destroy
    render json: true
  end
end
