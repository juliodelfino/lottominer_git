require 'sendgrid-ruby'

class ArticlesController < ApplicationController
  def index
    @articles = Article.all
    @results = LottoResult.all
    
    send_lotto_mail
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
    
    def send_lotto_mail
  
      client = SendGrid::Client.new(api_key: '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')
      
      mail = SendGrid::Mail.new do |m|
        m.to = 'jhackr@gmail.com'
        m.from = 'taco@cat.limo'
        m.subject = 'Notification from Lottominer'
        m.text = 'I heard you like pineapple.'
      end
    
      res = client.send(mail)
      @resp = LottoResult.create(game: res.code, numbers: res.body, won: false)
      @resp.save
    end
end
