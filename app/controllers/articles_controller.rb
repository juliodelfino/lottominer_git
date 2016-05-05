class ArticlesController < ApplicationController
  def index
    Article.delete_all
    LottoResult.delete_all
    @articles = Article.all
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
end
