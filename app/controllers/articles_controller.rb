require 'sendgrid-ruby'

class ArticlesController < ApplicationController
  def index
    @articles = Article.all
    @results = LottoResult.all
    
    @res = generate_result
    send_lotto_mail(@res)
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
      result = LottoResult.create(game: "SuperLotto 6/49", numbers: generate_random(), won: false)
      result.save
      return result
    end
    
    def generate_random
      nums = []
      while nums.size < 6 do
        num = rand(1..49)
        unless nums.include?(num) 
          nums << num
        end
      end
      return nums.sort.join(" ")
    end
    
    def send_lotto_mail(mail_info)
      
      client = SendGrid::Client.new(api_key: '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')
      
      mail = SendGrid::Mail.new do |m|
        m.to = 'jhackr@gmail.com'
        m.from = 'sofia@lottominer.com'
        m.subject = 'Notification from Lottominer ' + DateTime.now.strftime(" on %m-%d-%Y at at %I:%M%p")
        m.text = 'Here are the lotto results:<br>Game: ' + mail_info.game + "<br>Results: " + mail_info.numbers
      end
    
      res = client.send(mail)
      @resp = LottoResult.create(game: res.code, numbers: res.body, won: false)
      @resp.save
    end
end
