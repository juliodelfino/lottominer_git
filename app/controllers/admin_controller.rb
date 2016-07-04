class AdminController < ApplicationController
  before_filter :check_admin_role
  
  def index
    @selected_table = params[:table].nil? ? 'FbUser' : params[:table]
    clazz = @selected_table.constantize
    @column_names = clazz.columns.map {|c| c.name }
    @db_table_list = ActiveRecord::Base.connection.tables.map do |model|
      model.capitalize.singularize.camelize
    end
  end
  
  def get_db_table
    @selected_table = params[:table].nil? ? 'FbUser' : params[:table]
    clazz = @selected_table.constantize
    @column_names = clazz.columns.map {|c| c.name }
    render action: '_db_table', layout: false
  end
  
  def ajax_get_results2
    render json: File.read(File.dirname(__FILE__) + "/../../tmp/lotto_results.json")
  end
  
  def ajax_get_results
    
    @selected_table = params[:table].nil? ? 'LottoResult' : params[:table]
    
    clazz = @selected_table.constantize
    
    columns = clazz.columns.map { |col| col.name }
    result = clazz.all
    
    jsonResult = {
      columns: columns.map{ |col| {title: col } },
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
  
  private
    def check_admin_role
      if !current_user.is_admin?
        redirect_to root_path
      end
  end
end
