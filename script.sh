#!/bin/bash

# === Конфигурация по умолчанию ===
DEFAULT_CONDA_ENV_NAME="ont_cluster"
DEFAULT_CONDA_DIR="$HOME/miniconda3"
DEFAULT_DB_PATH=""
DEFAULT_RESULT_DIR="result"
DEFAULT_CLUSTER_DIR="ont_clustering"
DEFAULT_SEQUENCES_DIR="sequences"
DEFAULT_TRIM_DIR="trim_sequences"

# === Функции ===

# Вывод справки
show_help() {
    echo "Использование: $0 [опции]"
    echo ""
    echo "Опции:"
    echo "  --conda-env      Имя окружения Conda (по умолчанию: $DEFAULT_CONDA_ENV_NAME)"
    echo "  --conda-dir      Путь к Conda (по умолчанию: $DEFAULT_CONDA_DIR)"
    echo "  --db-path        Путь к базе данных BLAST (по умолчанию: $DEFAULT_DB_PATH)"
    echo "  --result-dir     Директория для сохранения результатов (по умолчанию: $DEFAULT_RESULT_DIR)"
    echo "  --cluster-dir    Рабочая директория с кластерными данными (по умолчанию: $DEFAULT_CLUSTER_DIR)"
    echo "  --sequences-dir  Директория с исходными FASTQ-файлами (по умолчанию: $DEFAULT_SEQUENCES_DIR)"
    echo "  --trim-dir       Директория для обрезанных FASTQ-файлов (по умолчанию: $DEFAULT_TRIM_DIR)"
    echo "  -h, --help       Показать эту справку и выйти"
}

check_directory() {
    local dir="$1"
    local description="$2"
    if [[ ! -d "$dir" ]]; then
        echo "Создаётся директория для $description: $dir"
        mkdir -p "$dir" || { echo "Ошибка: не удалось создать директорию $dir."; exit 1; }
    fi
}

trim_sequences() {
    local sequences_dir="$1"
    local trim_dir="$2"

    check_directory "$trim_dir" "обрезанных последовательностей"

    for ((i = 2; i < 12; i++)); do
        local input_file="${sequences_dir}/${i}.fastq"
        local output_file="${trim_dir}/trim_${i}.fastq"

        echo "Trimming ${i}.fastq..."

        if [[ ! -f "$input_file" ]]; then
            echo "Warning: File ${input_file} does not exist, skipping."
            continue
        fi

        exec 3>"$output_file"
        while IFS= read -r id && IFS= read -r seq && IFS= read -r plus && IFS= read -r score; do
            trimmed_seq="${seq:80}"
            trimmed_score="${score:80}"
            echo "$id" >&3
            echo "${trimmed_seq:0:700}" >&3
            echo "+" >&3
            echo "${trimmed_score:0:700}" >&3
        done < "$input_file"
        exec 3>&-

        echo "Finished trimming ${i}.fastq."
    done
}

cluster_data() {
    local cluster_dir="$1"
    local trim_dir="$2"
    local conda_env="$3"
    local conda_dir="$4"

    source "${conda_dir}/etc/profile.d/conda.sh"
    conda activate "$conda_env"

    for ((i = 2; i < 12; i++)); do
        cd "$cluster_dir"
        local input_file="${trim_dir}/trim_${i}.fastq"

        echo "Clustering ${i}.fastq..."

        python ont_cluster.py -r "$input_file" -k 6 \
            --png "umap_hdbscan_plot_${i}.png" \
            --cluster "umap_hdbscan_plot_${i}.tsv" \
            --kout "kmer_freq_${i}.csv"

        local n=$(awk '{print $5}' "umap_hdbscan_plot_${i}.tsv" | sort -n | tail -n 1)

        for ((j = -1; j <= n; j++)); do
            sed 1d "umap_hdbscan_plot_${i}.tsv" | awk -v var="$j" '$5 == var' | cut -f 1 > "cluster_${j}.id.txt"
            seqkit grep -f "cluster_${j}.id.txt" "$input_file" -o "cluster_${j}.fastq"
            bash assem.sh "cluster_${j}.fastq"
        done

        mkdir "${i}_clusters"
        mv cluster* "${i}_clusters"
        mv umap_hdbscan_plot* "${i}_clusters"
        mv kmer_freq_${i}.csv "${i}_clusters"
    done

    conda deactivate
}

# Выравнивание с помощью BLAST
align_sequences() {
    local cluster_dir="$1"
    local result_dir="$2"
    local db_path="$3"

    check_directory "$result_dir" "результатов BLAST"

    for ((i = 2; i < 12; i++)); do
        local cluster_dir="${cluster_dir}/${i}_clusters"
        local aligns_file="${result_dir}/aligns_${i}.tsv"

        if [[ ! -d "$cluster_dir" ]]; then
            echo "Warning: Directory ${cluster_dir} does not exist, skipping."
            continue
        fi

        [[ -f "$aligns_file" ]] && rm "$aligns_file"

        local n=$(awk '{print $5}' "${cluster_dir}/umap_hdbscan_plot_${i}.tsv" | sort -n | tail -n 1)

        for ((j = -1; j <= n; j++)); do
            local query_file="${cluster_dir}/cluster_${j}/consensus/cluster_${j}.consensus_medaka.fasta"
            local output_file="${cluster_dir}/cluster_${j}/consensus/align.tsv"

            echo "Processing ${query_file}..."

            if [[ ! -f "$query_file" ]]; then
                echo "Warning: File ${query_file} does not exist, skipping."
                continue
            fi

            blastn -db "$db_path" -query "$query_file" -outfmt 6 -num_alignments 1 > "$output_file"
            if [[ $? -eq 0 ]]; then
                head -n 1 "$output_file" >> "$aligns_file"
            else
                echo "Error: Blastn failed for ${query_file}."
            fi
        done

        echo "All alignments for cluster ${i} have been saved to ${aligns_file}."
    done
}

# === Основная логика ===
main() {
    # Переменные
    CONDA_ENV_NAME="$DEFAULT_CONDA_ENV_NAME"
    CONDA_DIR="$DEFAULT_CONDA_DIR"
    DB_PATH="$DEFAULT_DB_PATH"
    RESULT_DIR="$DEFAULT_RESULT_DIR"
    cluster_dir="$DEFAULT_cluster_dir"
    SEQUENCES_DIR="$DEFAULT_SEQUENCES_DIR"
    TRIM_DIR="$DEFAULT_TRIM_DIR"

    # Парсинг аргументов
    while [[ "$#" -gt 0 ]]; do
        case "$1" in
            --conda-env) CONDA_ENV_NAME="$2"; shift 2 ;;
            --conda-dir) CONDA_DIR="$2"; shift 2 ;;
            --db-path) DB_PATH="$2"; shift 2 ;;
            --result-path) RESULT_DIR="$2"; shift 2 ;;
            --cluster-dir) cluster_dir="$2"; shift 2 ;;
            --sequences-dir) SEQUENCES_DIR="$2"; shift 2 ;;
            --trim-dir) TRIM_DIR="$2"; shift 2 ;;
            -h|--help) show_help; exit 0 ;;
            *) echo "Неизвестная опция: $1"; show_help; exit 1 ;;
        esac
    done

    # Выполнение этапов
    trim_sequences "$SEQUENCES_DIR" "$TRIM_DIR"
    cluster_data "$cluster_dir" "$TRIM_DIR" "$CONDA_ENV_NAME" "$CONDA_DIR"
    align_sequences "$cluster_dir" "$RESULT_DIR" "$DB_PATH"
}

main "$@"
