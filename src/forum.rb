class Forum
  attr_accessor :threads

  SECTIONS = %w[/b/ /m/ /tech/ /art/]

  COMMON_RUSSIAN_WORDS = %w[и в не на с что я он она это как да ты был бы все]
  
  BLACKLISTED_WORDS = %w[группа реклама акция выигрыш подарок] # Пример черного списка

  def initialize
    @threads = []
    load_threads
  end

  def add_thread(title, section)
    id = @threads.length
    @threads << { id: id, title: title, section: section, comments: [], last_active: Time.now.iso8601 }
    message = "🟢 *Yoda Alert!*\n\nБыл создан новый тред - #{title} (#{section})\n\nhttps://dassie-moral-gator.ngrok-free.app#{section}thread/#{id}\n\n@Y0D9ch"

    send_telegram_message(message, false) # Отправляем в обычный чат
    
    puts "Добавляем тред: #{title} в раздел: #{section}" # Отладочный вывод
    save_threads
    id
  end
  
  def add_comment(thread_id, comment)
    thread_index = @threads.find_index { |thread| thread[:id] == thread_id }

    if thread_index
      if spam_detected?(thread_index, comment)
        return
      end

      @threads[thread_index][:comments] << comment
      @threads[thread_index][:last_active] = Time.now.iso8601 
      save_threads
      
      message = "🟢 *Yoda Alert!*\n\nБыл создан новый комментарий: ```\n#{comment}\n```\n\n[>>> Перейти к треду](https://dassie-moral-gator.ngrok-free.app#{@threads[thread_index][:section]}thread/#{thread_id})\n\n@Y0D9ch"
      send_telegram_message(message, false) # Отправляем в обычный чат
      
    else
      puts "Неверный идентификатор треда: #{thread_id}" # Отладочный вывод
    end
  end

  private

  def send_telegram_message(message, raid_alert = false)
    chat_id = raid_alert ? File.read("bot.chid") : File.read("bot.chatid") # Замените на ID другого чата

    Telegram::Bot::Client.run(File.read("bot.token")) do |bot|
      bot.api.send_message(chat_id: chat_id, text: message, parse_mode: 'Markdown')
    end
  end

  def spam_detected?(thread_index, comment)
    normalized_comment = comment.downcase # Приводим комментарий к нижнему регистру

    return false if contains_url?(normalized_comment) # Игнорируем комментарии с URL

    recent_comments = @threads[thread_index][:comments].last(2)

    # Проверка на повторяющиеся комментарии
    if recent_comments.size == 2 && recent_comments.all? { |c| c.downcase == normalized_comment }
      handle_spam_alert(thread_index)
      return true
    end

    # Проверка на наличие черных слов и паттернов спама
    if contains_blacklisted_words?(normalized_comment) || floating_point_spam?(normalized_comment) || repeated_character?(normalized_comment) || contains_repeated_patterns?(normalized_comment) || floating_point_with_text?(normalized_comment)
      handle_spam_alert(thread_index)
      return true
    end
    
    false 
  end

  def handle_spam_alert(thread_index)
    current_time = Time.now

    last_spam_alert_time = @threads[thread_index][:last_spam_alert_sent]
    
    # Приводим last_spam_alert_time к объекту Time, если это строка
    last_spam_alert_time = Time.parse(last_spam_alert_time) if last_spam_alert_time.is_a?(String)

    if last_spam_alert_time.nil? || (current_time - last_spam_alert_time > 300)
      message = "🚫 *Yoda Alert!*\n\nАвтомод среагировал на рейд. Рейд был отбит.\n\n@Y0D9ch | @Y0D9alerts"
      send_telegram_message(message, true) # Отправляем только рейд-алерт в канал

      @threads[thread_index][:last_spam_alert_sent] = current_time.iso8601 # Сохраняем как строку в ISO формате
    end
  end

  def contains_blacklisted_words?(comment)
    BLACKLISTED_WORDS.any? { |word| comment.include?(word) }
  end

  def contains_url?(comment)
    # Проверяем наличие URL в комментарии (нечувствительно к регистру)
    comment.match?(/https?:\/\/[\S]+/) || comment.match?(/www\.[\S]+/)
  end

  def random_number?(comment)
    comment.match?(/^\d+$/) || comment.match?(/^(?:\d+\s*){3,}$/) 
  end

  def nonsensical_message?(comment)
    words = comment.split(/\s+/).map(&:downcase)
    
    meaningful_words_count = words.count { |word| !COMMON_RUSSIAN_WORDS.include?(word) }
    
    meaningful_words_count < 2 # Считаем бессмысленным, если найдено менее двух значимых слов
  end

  def repeated_character?(comment)
    return false if comment.empty?
    
    comment.chars.uniq.length == 1 # Если все символы одинаковые, длина уникальных символов будет равна 1.
  end

  def floating_point_spam?(comment)
    has_floating_point_numbers = comment.scan(/\d+\.\d+/).any?
    
    has_repeated_sequences = comment.match?(/([A-Za-z])\1{2,}/)

    has_floating_point_numbers && has_repeated_sequences
  end
  
  def contains_repeated_patterns?(comment)
    # Проверка на наличие повторяющихся паттернов (например, "abcabc" или "123123")
    comment.match?(/(.+)\1/)
  end
  
  def floating_point_with_text?(comment)
    # Проверяем наличие чисел с плавающей запятой рядом с текстом (например, "0.631464 РЕДВИЖН")
    comment.match?(/\d+\.\d+\s+[A-Za-zА-Яа-я]+/)
  end

  def save_threads
    File.open('threads.json', 'w') do |file|
      file.write(JSON.pretty_generate(@threads))
    end
  end

  def load_threads
    if File.exist?('threads.json')
      @threads = JSON.parse(File.read('threads.json'), symbolize_names: true)
      @threads.each do |thread|
        thread[:last_active] ||= Time.now.iso8601 
        thread[:spam_alert_sent] ||= false 
        thread[:last_spam_alert_sent] ||= nil # Инициализируем переменную для времени последнего сообщения о спаме
      end
    end
end
end