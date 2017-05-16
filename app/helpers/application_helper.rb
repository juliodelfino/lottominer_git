module ApplicationHelper

  def ball_view(txt_numbers)
    return raw txt_numbers.split('-').map{|x| '<span class="ball">' + x + '</span>'}.join('<span class="small-dash">~</span>');
  end
end

