input_dir="$1" # Входная директория
output_dir="$2" # Выходная директория

# Проверяем существует ли директория, если нет - то создаем
if [ ! -d "$output_dir" ]; then
    mkdir -p "$output_dir"
fi


# Проверка на поддержку опции --backup=numbered
tempfile=$(mktemp)
if cp --backup=numbered "$tempfile" "${tempfile}_backup" &>/dev/null; 
then
    backup_supported=true
    rm "${tempfile}_backup"
else
    backup_supported=false
    echo "Опция cp --backup=numbered не поддерживается, копирование может работать некорректно."
fi
rm "$tempfile"

backup_file() {
    local dest_file="$1"

    if [ -e "$dest_file" ]; then
        local backup_number=1
        local backup_file="${dest_file}.~${backup_number}~"

        while [ -e "$backup_file" ]; do
            backup_number=$((backup_number + 1))
            backup_file="${dest_file}.~${backup_number}~"
        done

        mv "$dest_file" "$backup_file"
    fi
}


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
        
        if [ "$backup_supported" = true ]; then
            cp --backup=numbered "$file" "$dest_file"
        else
            backup_file "$dest_file"
            cp "$file" "$dest_file"
        fi
        
    done < <(find "$source_dir" -type f -print0)
}

copy_files "$input_dir" "$output_dir"
