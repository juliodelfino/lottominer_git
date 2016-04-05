class ArticlesController < ApplicationController
  def index
    @articles = Article.all
    generate_result
    @results = LottoResult.all
  end
  
  def show
    @article = Article.find(params[:id])
  end
  
  def new
  end
  
  # def create
    # render plain: params[:article].inspect
  # end
  def create
    @article = Article.new(article_params)
   
    @article.save
    redirect_to @article
  end
   
  private
    def article_params
      params.require(:article).permit(:title, :text)
    end
    
    def generate_result
      @result = LottoResult.create(game: "MegaLotto 6/49", numbers: "3 6 8 12 16 18", won: false)
      @result.save
    end
end
