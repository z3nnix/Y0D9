class Forum
  attr_accessor :threads

  SECTIONS = %w[/b/ /m/ /tech/ /art/]

  def initialize
    @threads = []
    load_threads
  end


  def add_thread(title, section)
    id = @threads.length # Use array length as unique identifier
    @threads << { id: id, title: title, section: section, comments: [], last_active: Time.now.iso8601 }
    message = "🟢 *Yoda Alert!*\n\nБыл создан новый тред - #{title} (#{section})\n\nhttps://dassie-moral-gator.ngrok-free.app#{section}thread/#{id}   \n\n@Y0D9ch"
    
    Telegram::Bot::Client.run(File.read("bot.token")) do |bot|
      bot.api.send_message(chat_id: File.read("bot.chatid"), text: message, parse_mode: 'Markdown')
    end
    
    puts "Adding thread: #{title} in section: #{section}" # Debugging output
    save_threads
    id # Return the new thread's identifie
  end
  
  def add_comment(thread_id, comment)
    thread_index = @threads.find_index { |thread| thread[:id] == thread_id }
  
    if thread_index
      # Получаем последние два комментария
      recent_comments = @threads[thread_index][:comments].last(2)
  
      # Проверяем, если есть хотя бы два комментария и они одинаковые
      if recent_comments.size == 2 && recent_comments.all? { |c| c == comment }
        # Проверяем, был ли уже отправлен сигнал о спаме
        if @threads[thread_index][:spam_alert_sent].nil? || !@threads[thread_index][:spam_alert_sent]
          # Отправляем уведомление о спаме
          message = "🚫 *Yoda Alert!*\n\nАвтомод среагировал на рейд. Рейд был отбит.\n\n@Y0D9ch"
          Telegram::Bot::Client.run(File.read("bot.token")) do |bot|
            bot.api.send_message(chat_id: File.read("bot.chatid"), text: message, parse_mode: 'Markdown')
          end
          
          # Устанавливаем флаг, что уведомление о спаме было отправлено
          @threads[thread_index][:spam_alert_sent] = true
        end
  
        # Игнорируем комментарий, если он повторяется более двух раз подряд
        return
      else
        # Сбрасываем флаг, если комментарий не является спамом
        @threads[thread_index][:spam_alert_sent] = false
      end
  
      # Добавляем комментарий и обновляем время последней активности
      @threads[thread_index][:comments] << comment
      @threads[thread_index][:last_active] = Time.now.iso8601 
      save_threads
  
      # Подготавливаем сообщение
      file = File.read('threads.json')
      data = JSON.parse(file)
  
      # Указываем ID для поиска
      id_to_find = 12
  
      # Находим раздел для указанного ID
      entry = data.find { |item| item["id"] == id_to_find }
  
      message = "🟢 *Yoda Alert!*\n\nБыл создан новый комментарий: ```\n#{comment}\n```\n\n[>>> Перейти к треду](https://dassie-moral-gator.ngrok-free.app#{entry["section"]}thread/#{thread_id})\n\n@Y0D9ch"
  
      Telegram::Bot::Client.run(File.read("bot.token")) do |bot|
        bot.api.send_message(chat_id: File.read("bot.chatid"), text: message, parse_mode: 'Markdown')
      end
  
    else
      puts "Invalid thread id: #{thread_id}" # Отладочный вывод
    end
  end
  
  
  
  private

  def save_threads
    File.open('threads.json', 'w') do |file|
      file.write(JSON.pretty_generate(@threads))
    end
  end

  def load_threads
    if File.exist?('threads.json')
      @threads = JSON.parse(File.read('threads.json'), symbolize_names: true)
      # Ensure all threads have a last_active value
      @threads.each do |thread|
        thread[:last_active] ||= Time.now.iso8601 # Set to current time if nil
      end
    end
  end
end
