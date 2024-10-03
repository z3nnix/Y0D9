def last_thread_id(file_path)
  # Читаем содержимое файла
  file_content = File.read(file_path)

  # Парсим JSON
  threads = JSON.parse(file_content)

  # Проверяем, есть ли элементы в массиве
  if threads.is_a?(Array) && !threads.empty?
    # Получаем ID последнего элемента
    last_id = threads.last['id']
    return last_id
  else
    return nil # Возвращаем nil, если массив пустой или не является массивом
  end
end