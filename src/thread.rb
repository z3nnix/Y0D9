def add_thread(title, section)
    attr_accessor :threads

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