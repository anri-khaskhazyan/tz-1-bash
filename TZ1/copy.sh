input_dir="$1" # Входная директория
output_dir="$2" # Выходная директория

# Проверяем существует ли директория, если нет - то создаем
if [ ! -d "$output_dir" ]; then
    mkdir -p "$output_dir"
fi

copy_files() {
    local source_dir="$1"
    local dest_dir="$2"

    # Проходим по файлам во входной директории
    # Команда find ищет файлы, и выводит их с разделителем \0 вместо новой строки (для совместимости)
    # Считываем каждое имя файла с нулевым разделителем, найденное find, в переменную file
    # IFS=: Удаляем Internal Field Separator, что обеспечивает сохранение пробелов и других пробельных символов в именах файлов.
    while IFS= read -r -d '' file; do
        file_basename=$(basename -- "$file")
        dest_file="$dest_dir/$file_basename"
        
        cp --backup=numbered "$file" "$dest_file"
        
    done < <(find "$source_dir" -type f -print0)
}

copy_files "$input_dir" "$output_dir"
