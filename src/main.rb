# include libraries
require 'webrick'
require 'uri'
require 'json'
require 'time'
require 'telegram/bot'

# include realization
require_relative 'forum.rb'
require_relative 'engine/utils.rb'

forum = Forum.new
server = WEBrick::HTTPServer.new(Port: 8000)

# Главная страница с формой для создания треда
server.mount_proc '/' do |req, res|
  set_utf8_headers(res)

  if req.request_method == 'POST'
    # Извлечение названия треда и раздела из тела запроса
    params = URI.decode_www_form(req.body).to_h
    title = params['title'].strip
    section = params['section']

    unless title.empty? && !section.nil?
      thread_id = forum.add_thread(title, section) # Получаем идентификатор нового треда
      res.set_redirect(WEBrick::HTTPStatus::SeeOther, "#{section}thread/#{thread_id}") # Перенаправляем на страницу треда с новым URL форматом
      return
    end
  end

  # Отображение главной страницы, сортировка по времени последней активности (от самого активного к наименее активному)
  sorted_threads = forum.threads.sort_by { |thread| thread[:last_active] || Time.at(0).iso8601 }.reverse
  
  eval(File.read("src/frontend/index.html"))
end

server.mount_proc '/rules' do |req, res|
  set_utf8_headers(res)

  if req.request_method == 'POST'
    # Извлечение названия треда и раздела из тела запроса
    params = URI.decode_www_form(req.body).to_h
    title = params['title'].strip
    section = params['section']

    unless title.empty? && !section.nil?
      thread_id = forum.add_thread(title, section) # Получаем идентификатор нового треда
      res.set_redirect(WEBrick::HTTPStatus::SeeOther, "#{section}thread/#{thread_id}") # Перенаправляем на страницу треда с новым URL форматом
      return
    end
  end

  # Отображение главной страницы, сортировка по времени последней активности (от самого активного к наименее активному)
  sorted_threads = forum.threads.sort_by { |thread| thread[:last_active] || Time.at(0).iso8601 }.reverse
  
  eval(File.read("src/frontend/rules.html"))
end

server.mount_proc '/b/thread' do |req, res|
  handle_thread_request(req, res, forum, '/b/')
end

server.mount_proc '/m/thread' do |req, res|
  handle_thread_request(req, res, forum, '/m/')
end

server.mount_proc '/tech/thread' do |req, res|
  handle_thread_request(req, res, forum, '/tech/')
end

server.mount_proc '/art/thread' do |req, res|
  handle_thread_request(req, res, forum, '/art/')
end

require_relative "handlethread.rb"

trap('INT') { server.shutdown }

server.start  
