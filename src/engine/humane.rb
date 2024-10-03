def human_readable_size(file_path)
  size_in_bytes = File.size(file_path)

  # Определяем единицы измерения
  units = ['байт', 'КБ', 'МБ', 'ГБ', 'ТБ']
  index = 0

  # Преобразуем размер в более удобный формат
  while size_in_bytes >= 1024 && index < units.length - 1
    size_in_bytes /= 1024.0
    index += 1
  end

  # Форматируем вывод с двумя знаками после запятой
  "#{size_in_bytes.round(2)} #{units[index]}"
end