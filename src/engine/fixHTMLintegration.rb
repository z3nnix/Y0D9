def escape_html(text)
  # Экранирование специальных HTML-символов, кроме "
  text.gsub!('&', '&amp;')
  text.gsub!("'", '&#39;')
  # Символы < и > экранируются позже
  text
end

def convert_links_to_html(text)
  url_regex = /(https?:\/\/[^\s]+)/i
  hashtag_regex = /#(\w+)/ # Регулярное выражение для поиска хештегов
  
  # Определяем общий цвет для ссылок и хештегов
  link_color = '#00bfff' # Ярко-голубой цвет


  # Заменяем код на специальный маркер
  text.gsub!(/<code>(.*?)<\/code>/, '[[CODE:\1]]')

  # Проверяем, было ли уже экранирование выполнено
  if !text.include?('&lt;') && !text.include?('&gt;') && !text.include?('&amp;')
    # Экранируем текст от HTML/JS/CSS вставок
    text = escape_html(text)
    
    # Экранируем символы < и > после обработки тегов
    text.gsub!('<', '&lt;')
    text.gsub!('>', '&gt;')
  end

  # Восстанавливаем код после экранирования
  text.gsub!(/\[\[CODE:(.*?)\]\]/, '<code>\1</code>')

  # Заменяем ссылки на HTML
  text = text.gsub(url_regex) do |url|
    "<a href='#{url}' style='color: lightskyblue;'>#{url}</a>"
  end

  # Заменяем хештеги на HTML (без знака #)
  text.gsub!(hashtag_regex) do |hashtag|
    "<span style='color: #{link_color}; font-weight: bold;'>#{hashtag}</span>"
  end


  text.gsub!(/\*\*(.+?)\*\*/, '<strong>\1</strong>')
  text.gsub!(/\`\`(.+?)\`\`/, '<code>\1</code>')

  if text.length > 147
    text = text.scan(/.{1,147}/).join("<br/>")
  end

  text
end